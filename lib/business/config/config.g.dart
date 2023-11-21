// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig()
  ..stunServer =
      json['stun_server'] as String? ?? 'turn:stun.ketanetwork.cc:3478'
  ..stunUserName = json['stun_user'] as String? ?? 'test'
  ..stunPassword = json['stun_pwd'] as String? ?? 'test';

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'stun_server': instance.stunServer,
      'stun_user': instance.stunUserName,
      'stun_pwd': instance.stunPassword,
    };
