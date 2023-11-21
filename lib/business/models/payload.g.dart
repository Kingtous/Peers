// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payload _$PayloadFromJson(Map<String, dynamic> json) => Payload()
  ..type = $enumDecode(_$ActionTypeEnumMap, json['type'])
  ..data = json['data'] as Map<String, dynamic>?;

Map<String, dynamic> _$PayloadToJson(Payload instance) => <String, dynamic>{
      'type': _$ActionTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$ActionTypeEnumMap = {
  ActionType.voiceCall: 'voiceCall',
  ActionType.videoCall: 'videoCall',
  ActionType.chat: 'chat',
  ActionType.quit: 'quit',
  ActionType.ping: 'ping',
  ActionType.answer: 'answer',
};

Event _$EventFromJson(Map<String, dynamic> json) => Event()
  ..from = json['from'] as String
  ..target = json['target'] as String
  ..payload = json['payload'] == null
      ? null
      : Payload.fromJson(json['payload'] as Map<String, dynamic>);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'from': instance.from,
      'target': instance.target,
      'payload': instance.payload,
    };
