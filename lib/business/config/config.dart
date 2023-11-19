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

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:keta_peers/constants.dart';
import 'package:keta_peers/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'config.g.dart';

const kConfigKey = 'conf';

@JsonSerializable()
class AppConfig {
  @JsonKey(name: 'stun_server', defaultValue: kDefaultStunServer)
  late String stunServer;

  static late AppConfig _config;
  static AppConfig get instance => _config;
  static void init() async {
    final config = it.get<SharedPreferences>().getString(kConfigKey) ?? "{}";
    final Map<String, dynamic> confMap = jsonDecode(config);
    _config = fromJson(confMap);
  }

  static AppConfig fromJson(Map<String, dynamic> json) {
    return _$AppConfigFromJson(json);
  }

  static Map<String, dynamic> toJson(AppConfig config) {
    return _$AppConfigToJson(config);
  }

  static Future<void> apply() async {
    await it
        .get<SharedPreferences>()
        .setString(kConfigKey, jsonEncode(toJson(_config)));
  }
}
