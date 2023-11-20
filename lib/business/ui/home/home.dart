import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:keta_peers/constants.dart';
import 'package:keta_peers/services.dart';
import 'package:keta_peers/services/signaling_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  SignalingClient get client => it.get();
  late RTCVideoRenderer localRenderer;

  @override
  void initState() {
    super.initState();
    final r = RTCVideoRenderer();
    localRenderer = r;
    r.initialize().then((_) {
      kLogger.d('RTCVideoRenderer initialized');
      r.srcObject = client.iceConnection!.stream;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    localRenderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RTCVideoView(
          localRenderer,
          placeholderBuilder: (context) => Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: ProgressRing(),
            ),
          ),
        ),
        Row(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey
                ),
                child: Column(
                children: [
              TextBox()
                ],
                          ),
              )),
            Flexible(
              flex: 5,
              child: Column(
              children: [

              ],
            )),
          ],
        )
      ],
    );
  }
}
