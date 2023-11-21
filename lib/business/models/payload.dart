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

import 'package:json_annotation/json_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'payload.g.dart';

enum ActionType {
  voiceCall,
  videoCall,
  chat,
  quit,
  ping,
  answer,
}

const kEventMessageSinglePeer = 'messageOne';
const kEventMessageBroadcast = 'message';

@JsonSerializable()
class Payload {
  late ActionType type;
  late Map<String, dynamic>? data;

  Map<String, dynamic> toJson() {
    return _$PayloadToJson(this);
  }

  static Payload fromJson(Map<String, dynamic> json) {
    return _$PayloadFromJson(json);
  }
}

@JsonSerializable()
class Event {
  late String from;
  late String target;
  Payload? payload;

  Map<String, dynamic> toJson() {
    return _$EventToJson(this);
  }

  static Event fromJson(Map<String, dynamic> json) {
    return _$EventFromJson(json);
  }
}

Map<String, dynamic> buildEvent(String from, String target, Payload payload) {
  return {'from': from, 'target': target, 'payload': payload.toJson()};
}

void emitMessageToPeer(
    Socket emitter, String from, String target, Payload payload) {
  emitter.emit('messageOne', buildEvent(from, target, payload));
}

void emitBroadcastMessage(Socket emitter, String from, Payload payload) {
  emitter.emit('message', buildEvent(from, 'all', payload));
}
