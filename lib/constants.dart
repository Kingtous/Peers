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
import 'package:go_router/go_router.dart';
import 'package:keta_peers/business/ui/home/home.dart';
import 'package:keta_peers/business/ui/home/index.dart';
import 'package:keta_peers/main.dart';
import 'package:logger/logger.dart';

const kDefaultStunServer = "turn:stun.ketanetwork.cc:3478";
const kDefaultStunUser = "test";
const kDefaultStunPassword = "test";
const kDefaultSignalingServer = "https://peers.signaling.ketanetwork.cc";
const kPageIndex = '/index';
const kPageHome = '/home';
const kAppName = 'Peers';
final kLogger = Logger();
final kRoutes = GoRouter(routes: <GoRoute>[
  GoRoute(
    path: '/',
    builder: (context, state) => const WelcomePage(title: 'Peers'),
  ),
  GoRoute(
    path: kPageIndex,
    builder: (context, state) => const IndexPage(),
  ),
  GoRoute(
    path: kPageHome,
    builder: (context, state) => const ContactPage(),
  ),
]);
