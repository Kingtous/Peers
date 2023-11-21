// Copyright 2023 a1147
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:keta_peers/business/config/config.dart';
import 'package:keta_peers/business/models/payload.dart';
import 'package:keta_peers/constants.dart';
import 'package:keta_peers/services/ice_service.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:get/get.dart';

enum UserState {
  videoCalling,
  voiceCalling,
  idle,
  videoIncoming,
  voiceIncoming,
  invitingVideo,
  invitingVoice,
  cancelRequesting,
}

class SignalingClient {
  late Socket _signalingSocket;
  final RxBool _ready = false.obs;
  RxBool get ready => _ready;
  IceConnection? _iceConnection;
  IceConnection? get iceConnection => _iceConnection;
  late String peerId;

  late StreamController<Event> _eventSink;
  late Stream<Event> eventStream;
  late Rx<UserState> state;
  Map<String, dynamic>? incomingCall;

  /// Candidates of local
  final List<RTCIceCandidate> _candidates = [];

  /// UI callbacks
  Future<bool> Function(String peer)? onNewVideoCall;
  Future<bool> Function(String peer)? onNewVoiceCall;
  Function(MediaStream)? onRemoteStream;

  Future<void> init(String peerId) async {
    this.peerId = peerId;
    _eventSink = StreamController();
    eventStream = _eventSink.stream.asBroadcastStream();
    state = Rx(UserState.idle);
    _signalingSocket = io(
        kDefaultSignalingServer,
        OptionBuilder()
            .setTransports(['websocket'])
            .setTimeout(5000)
            .setExtraHeaders({'client': 'peers'})
            .setAuth({'token': kSignalingAuthKey})
            .build());
    _signalingSocket.onConnect(_onConnect);
    _signalingSocket.onDisconnect(_onDisconnect);
    _signalingSocket.onConnect((data) => null);
    _signalingSocket.on(kEventMessageSinglePeer, _onMessage);
    _signalingSocket.on(kEventMessageBroadcast, _onMessage);
    kLogger.d('Signaling server: connecting $kDefaultSignalingServer');
    final conn = await connectICEBackend(
        onIceCandidate: _onCandidate,
        onIceGatheringState: _onCandidateGatheringState);
    _iceConnection = conn;
    conn.conn.onTrack = _onTrack;
    eventStream.listen(_eventListener);
  }

  void dispose() {
    _iceConnection?.dispose();
    _signalingSocket.close();
  }

  _onConnect(dynamic data) {
    kLogger.d("Signaling server connected");
    _ready.value = true;
    // send ready
    _signalingSocket.emit('ready', peerId);
  }

  _onDisconnect(data) {
    _ready.value = false;
  }

  /// 负责自动回复
  _eventListener(Event evt) {
    // if (evt.target == peerId) {
    //   return;
    // }
    kLogger.d('eventListener: ${evt.payload?.type}');
    final payload = evt.payload!;
    switch (payload.type) {
      case ActionType.videoCall:
        if (state.value == UserState.videoCalling ||
            state.value == UserState.videoCalling) {
          sendPayload(
              Payload()
                ..type = ActionType.answer
                ..data = {'accept': false, 'reason': 'busy now'},
              target: evt.from);
          return;
        } else {
          incomingCall = payload.data;
          if (incomingCall == null) {
            return;
          }
          state.value = UserState.videoIncoming;
          final tmp = incomingCall!;
          if (onNewVideoCall == null) {
            acceptVideoCall(false, evt.from, null);
          } else {
            onNewVideoCall?.call(evt.from).then((acc) {
              acceptVideoCall(acc, evt.from, tmp);
            });
          }
        }
        break;
      case ActionType.answer:
        if (state.value == UserState.invitingVideo) {
          if (payload.data?['accept'] == false) {
            _toIdle();
          } else if (payload.data?['accept'] == true) {
            _toVideoCall(payload.data?['answer']);
          } else {
            _toIdle();
          }
        } else if (state.value == UserState.invitingVoice) {
          // todo:
          if (payload.data?['accept'] == false) {
            _toIdle();
          } else if (payload.data?['accept'] == true) {
            // todo:
            throw UnimplementedError();
          } else {
            _toIdle();
          }
        } else {
          // ignore
        }
        break;
      case ActionType.quit:
        if (incomingCall?['peerId'] == evt.from) {
          _toIdle();
        }
        break;
      default:
        break;
    }
  }

  _toVideoCall(Map<String, dynamic> peerDesc) {
    iceConnection!.conn.setRemoteDescription(RTCSessionDescription(
        peerDesc['desc']['sdp'], peerDesc['desc']['type']));
    for (final candidate in peerDesc['candidates']) {
      iceConnection!.conn.addCandidate(RTCIceCandidate(candidate['candidate'],
          candidate['sdpMid'], candidate['sdpMLineIndex']));
    }
    incomingCall = peerDesc;
    state.value = UserState.videoCalling;
  }

  _toIdle() {
    state.value = UserState.idle;
    incomingCall = null;
  }

  _onMessage(data) {
    // onMessage

    try {
      final evt = Event.fromJson(data);
      kLogger.d(
          'recv ${evt.from}->${evt.target}: ${evt.payload?.type}, current state: ${state.value}');
      if (evt.target == 'all' || evt.from == "all") {
        // 先屏蔽掉，之后可能用得到
        kLogger.i('ignored this evt: ${evt.from}');
        return;
      }
      _eventSink.add(evt);
    } catch (e) {
      kLogger.e('message parse error: $e, origin data: ${data}');
    }
  }

  void quitCalling() {
    if (incomingCall != null) {
      sendPayload(
        Payload()
          ..type = ActionType.quit
          ..data = {},
        target: incomingCall!['peerId'],
      );
    }
    _toIdle();
  }

  void sendPayload(Payload payload, {String target = 'all'}) {
    if (target == 'all') {
      emitBroadcastMessage(_signalingSocket, peerId, payload);
    } else {
      emitMessageToPeer(_signalingSocket, peerId, target, payload);
    }
    kLogger.d('sent -> $target :${payload.type}');
  }

  void inviteVideoCall(String newPeerId) {
    if (iceConnection == null) {
      kLogger.e('ice connection lost!');
      return;
    }
    // Send offer to the peer.
    sendPayload(
        Payload()
          ..type = ActionType.videoCall
          ..data = {
            'offer': iceConnection!.localDesc.toMap(),
            'peerId': newPeerId,
            'candidates':
                _candidates.map((e) => e.toMap()).toList(growable: false)
          },
        target: newPeerId);
    state.value = UserState.invitingVideo;
  }

  void acceptVideoCall(
      bool accept, String fromPeerId, Map<String, dynamic>? offerDesc) {
    if (!accept) {
      kLogger.i("cancel this request from $fromPeerId");
      sendPayload(
          Payload()
            ..type = ActionType.answer
            ..data = {'accept': false, 'answer': null},
          target: fromPeerId);
      _toIdle();
      return;
    }
    kLogger.i("accepting video call from $fromPeerId");
    // 设置为远端的candidate
    kLogger.d(
        'has set remote description and ${offerDesc?['candidates'].length} candidates.');
    iceConnection!.conn.setRemoteDescription(RTCSessionDescription(
        offerDesc!['offer']['sdp'], offerDesc['offer']['type']));
    for (final candidate in offerDesc['candidates']) {
      iceConnection?.conn.addCandidate(RTCIceCandidate(candidate['candidate'],
          candidate['sdpMid'], candidate['sdpMLineIndex']));
    }
    iceConnection!.createAnswer().then(
      (answer) {
        sendPayload(
            Payload()
              ..type = ActionType.answer
              ..data = {
                'accept': accept,
                'answer': accept
                    ? {
                        'desc': answer.toMap(),
                        'peerId': peerId,
                        'candidates': _candidates
                            .map((e) => e.toMap())
                            .toList(growable: false)
                      }
                    : null
              },
            target: fromPeerId);
      },
    );
    state.value = UserState.videoCalling;
  }

  _onCandidate(RTCIceCandidate candidate) {
    _candidates.add(candidate);
    kLogger.i("add ice candidate: ${candidate.toMap()}");
  }

  _onCandidateGatheringState(RTCIceGatheringState candidate) {
    kLogger.i("ice gathering: $candidate");
    if (candidate == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      kLogger.i("candidates in local: $_candidates");
    }
  }

  _onTrack(RTCTrackEvent event) {
    kLogger.d("track event: ${event.track.kind}");
    if (event.track.kind == "video") {
      onRemoteStream?.call(event.streams[0]);
    }
  }
}
