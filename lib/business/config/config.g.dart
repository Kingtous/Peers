// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig()
  ..stunServer = json['stun_server'] as String? ??
      'stun:peers.signaling.ketanetwork.cc:3478';

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'stun_server': instance.stunServer,
    };
