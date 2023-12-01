import 'dart:async';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
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
    client.onRemoteStream = _onRemoteStream;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (client.state.value) {
        case UserState.videoCalling:
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: Stack(
                  children: [
                    RTCVideoView(
                      remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
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
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Peers Call - ${client.incomingCall?['peerId']}',
                        style: const TextStyle(color: Colors.white,),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Stack(
                    children: [
                      RTCVideoView(
                        localRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
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
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          client.peerId,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button(
                        style: ButtonStyle(
                            backgroundColor: ButtonState.all(Colors.red)),
                        child: const Text(
                          'Hang up',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          client.quitCalling();
                          remoteRenderer.srcObject = null;
                        })
                  ],
                ),
              )
            ],
          );
        default:
          var menuChildren = [
            const Expanded(
                flex: 5,
                child: Column(
                  children: [],
                )),
            Expanded(
                flex: 2,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(220),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            bottomLeft: Radius.circular(12))),
                    child: Column(
                      children: [
                        if (client.state.value == UserState.idle)
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8.0,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(width: 16.0),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                          onTap: () {
                                            context.replace(kPageIndex);
                                          },
                                          child: const Icon(
                                            FluentIcons.back,
                                            color: Colors.white,
                                          )),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Contact with your peers!',
                                        style: TextStyle(
                                            fontSize: 24.0,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(
                                        height: 12.0,
                                      ),
                                      Text(
                                        'Now login as ${client.peerId}',
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.white.withAlpha(200)),
                                      ),
                                      const SizedBox(
                                        height: 6.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: TextBox(
                                          placeholder: 'The ID of your peer',
                                          onChanged: (peerId) {
                                            callPeerId.value = peerId;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                      Button(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                ButtonState.all(Colors.blue),
                                            textStyle: ButtonState.all(
                                                const TextStyle(color: Colors.white)),
                                          ),
                                          onPressed: _toggleCall,
                                          child: Obx(() => Text(
                                                'Invoke Video Call with ${callPeerId.value}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (client.state.value ==
                                UserState.invitingVideo ||
                            client.state.value == UserState.invitingVoice)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Calling ${callPeerId.value}',
                                  style: const TextStyle(
                                      fontSize: 24.0, color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 8.0,
                                ),
                                Button(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          ButtonState.all(Colors.red),
                                      textStyle: ButtonState.all(
                                          const TextStyle(color: Colors.white)),
                                    ),
                                    onPressed: _toggleCall,
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
          ];
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
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: MediaQuery.of(context).size.height /
                                  MediaQuery.of(context).size.width >
                              1
                          ? Column(
                              children: menuChildren,
                            )
                          : Row(
                              children: menuChildren,
                            ),
                    ),
                  ],
                ),
              ),
              if (kDebugMode)
                Container(
                  alignment: Alignment.topRight,
                  child: Obx(() => Container(
                      decoration:
                          BoxDecoration(color: Colors.white.withAlpha(100)),
                      child: Text(
                        client.state.value.toString(),
                        style: const TextStyle(color: Colors.white),
                      ))),
                )
            ],
          );
      }
    });
  }

  void _toggleCall() {
    // todo: 目前只考虑视频通话
    if (client.state.value == UserState.idle) {
      client.inviteVideoCall(callPeerId.value);
    } else {
      client.quitCalling();
    }
  }

  Future<bool> _onNewVideoCall(String peer) async {
    kLogger.i('waiting for users');
    return (await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return ContentDialog(
                title: const Text('Invitation'),
                content: Text('Accept video call from $peer？'),
                actions: [
                  Button(
                      child: const Text('Accept'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      }),
                  Button(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      }),
                ],
              );
            })) ??
        false;
  }

  _onRemoteStream(MediaStream stream) {
    kLogger.d("add remote stream: ${stream.id} ${stream.getTracks()}");
    setState(() {
      remoteRenderer.srcObject = stream;
    });
  }
}
