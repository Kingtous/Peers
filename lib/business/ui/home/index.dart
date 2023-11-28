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

import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keta_peers/constants.dart';
import 'package:keta_peers/services.dart';
import 'package:keta_peers/services/signaling_service.dart';
import 'package:lottie/lottie.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  String id = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      child: Row(
        children: [
          Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        kAppName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.0,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                          height: 300,
                          width: 300,
                          child: LottieBuilder.asset(
                              'assets/animations/login.json'))
                    ],
                  ),
                ],
              )),
          Flexible(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(color: Colors.blue),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextBox(
                          onChanged: (text) {
                            id = text;
                          },
                        )),
                      ],
                    ),
                    Button(onPressed: toggleLogin, child: const Text('login'))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  toggleLogin() async {
    final client = SignalingClient();
    await client.init(id);
    if (client.ready.value) {
      onContextReady(client);
    }
    client.ready.listen((ready) {
      if (ready) {
        onContextReady(client);
      }
    });
  }

  onContextReady(SignalingClient client) {
    try {
      it.get<SignalingClient>().dispose();
      it.unregister<SignalingClient>();
    } catch (e) {
      // ignore
    }
    it.registerSingleton<SignalingClient>(client);
    context.go(kPageHome);
  }
}
