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

import 'package:keta_peers/business/config/config.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:keta_peers/constants.dart';

class IceConnection {
  late final RTCPeerConnection conn;
  late final MediaStream stream;
  late final RTCSessionDescription localDesc;

  void dispose() {
    stream.dispose();
  }

  Future<RTCSessionDescription> createAnswer() async {
    final desc = conn.createAnswer();
    return desc;
  }
}

Future<IceConnection> connectICEBackend(
    {Function(RTCIceCandidate candidate)? onIceCandidate,
    Function(RTCIceGatheringState candidate)? onIceGatheringState}) async {
  final mediaStream =
      await navigator.mediaDevices.getUserMedia({'audio': true, 'video': true});
  kLogger.d('tracks: ${mediaStream.getTracks()}');
  final conn = await createPeerConnection({
    'iceServers': [
      {
        'urls': AppConfig.instance.stunServer,
        'username': AppConfig.instance.stunUserName,
        'password': AppConfig.instance.stunPassword
      }
    ]
  });
  mediaStream.getTracks().forEach((track) {
    conn.addTrack(track, mediaStream);
  });
  final desc = await conn
      .createOffer({'offerToReceiveVideo': true, 'offerToReceiveAudio': true});
  conn.setLocalDescription(desc);
  conn.onIceCandidate = onIceCandidate;
  conn.onIceGatheringState = onIceGatheringState;

  return IceConnection()
    ..conn = conn
    ..stream = mediaStream
    ..localDesc = desc;
}
