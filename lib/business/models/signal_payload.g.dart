// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignalPayload _$SignalPayloadFromJson(Map<String, dynamic> json) =>
    SignalPayload()
      ..from = json['from'] as String
      ..target = json['target'] as String
      ..payload = json['payload'];

Map<String, dynamic> _$SignalPayloadToJson(SignalPayload instance) =>
    <String, dynamic>{
      'from': instance.from,
      'target': instance.target,
      'payload': instance.payload,
    };
