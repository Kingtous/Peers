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
  late RTCVideoRenderer remoteRenderer;
  var callPeerId = "".obs;

  @override
  void initState() {
    super.initState();
    // local renderer
    localRenderer = RTCVideoRenderer();
    localRenderer.initialize().then((_) {
      kLogger.d('RTCVideoRenderer initialized');
      localRenderer.srcObject = client.iceConnection!.stream;
      setState(() {});
    });
    remoteRenderer = RTCVideoRenderer();
    // as fast as flutter can.
    Future.microtask(() => remoteRenderer.initialize());
    registerUiCallback();
  }

  @override
  void dispose() {
    super.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
    client.dispose();
  }

  registerUiCallback() {
    client.onNewVideoCall = _onNewVideoCall;
    client.iceConnection?.conn.onAddTrack = (stream, track) {
      kLogger.d('got stream! ${track.id}');
      if (stream != client.iceConnection!.stream) {
        setState(() {
          remoteRenderer.srcObject = stream;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (client.state.value) {
        case UserState.videoCalling:
          return NavigationView(
            appBar: NavigationAppBar(
                title: const Text('通话中'),
                actions: Row(
                  children: [
                    Button(
                        child: const Text('挂断'),
                        onPressed: () {
                          client.quitCalling();
                        })
                  ],
                )),
            content: Column(
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: RTCVideoView(
                                  remoteRenderer,
                                  objectFit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                                  placeholderBuilder: (context) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: ProgressRing(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: RTCVideoView(
                                  remoteRenderer,
                                  objectFit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover,
                                  placeholderBuilder: (context) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: ProgressRing(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        default:
          return Stack(
            children: [
              RTCVideoView(
                localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                placeholderBuilder: (context) => const Center(
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
                        decoration: const BoxDecoration(color: Colors.grey),
                        child: Column(
                          children: [
                            TextBox(
                              onChanged: (peerId) {
                                callPeerId.value = peerId;
                              },
                            ),
                            Button(
                                onPressed: _toggleCall,
                                child: Obx(
                                    () => Text('开始与${callPeerId.value}视频通话')))
                          ],
                        ),
                      )),
                  const Flexible(
                      flex: 5,
                      child: Column(
                        children: [],
                      )),
                ],
              )
            ],
          );
      }
    });
  }

  void _toggleCall() {
    // todo: 目前只考虑视频通话
    client.inviteVideoCall(callPeerId.value);
  }

  Future<bool> _onNewVideoCall(String peer) async {
    return (await showDialog<bool>(
            context: context,
            builder: (context) {
              return ContentDialog(
                title: const Text('邀请'),
                content: Text('接受来自$peer的视频通话？'),
                actions: [
                  Button(
                      child: const Text('接受'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      }),
                  Button(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      }),
                ],
              );
            })) ??
        false;
  }
}
