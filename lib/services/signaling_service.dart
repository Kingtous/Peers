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
import 'package:keta_peers/constants.dart';
import 'package:keta_peers/services/ice_service.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:get/get.dart';

class SignalingClient {
  late Socket _signalingSocket;
  final RxBool _ready = false.obs;
  RxBool get ready => _ready;
  IceConnection? _iceConnection;
  late String peerId;
  void init(String peerId) {
    _signalingSocket = io(kDefaultSignalingServer);
    _signalingSocket.onConnect(_onConnect);
    _signalingSocket.onDisconnect(_onDisconnect);
    _signalingSocket.onConnect((data) => null);
    _signalingSocket.on('message', _onMessage);
    connectICEBackend().then((value) {
      _iceConnection = value;
    });
    this.peerId = peerId;
  }

  void dispose() {
    _iceConnection?.dispose();
    _signalingSocket.close();
  }

  _onConnect(dynamic data) {
    _ready.value = true;
    // send ready
    _signalingSocket.emit('ready', peerId);
  }

  _onDisconnect(data) {
    _ready.value = false;
  }

  _onMessage(data) {
    // onMessage
    kLogger.d('recv $data');
  }

  sendToPeer(data) {
    _signalingSocket.emit('messageOne', data);
  }
}
