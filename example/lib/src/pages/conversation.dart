import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:deepgram_sdk/models/tts_model.dart';
import 'package:example/src/core/extensions/context_extension.dart';
import 'package:example/src/core/routes/router.dart';
import 'package:example/src/core/services/deepgram_service.dart';
import 'package:example/src/core/services/groq_service.dart';
import 'package:example/src/core/utils/api_keys.dart';
import 'package:example/src/core/utils/logger.dart';
import 'package:example/src/pages/simli_avatar_view.dart';
import 'package:example/src/widgets/bg.dart';
import 'package:example/src/widgets/caption_box.dart';
import 'package:example/src/widgets/simli_avatar_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:simli_client/models/simli_client_config.dart';
import 'package:simli_client/simli_client.dart';
import 'package:transparent_image/transparent_image.dart';

class Conversations extends StatefulWidget {
  const Conversations({super.key, required this.avatarName});
  final String avatarName;

  @override
  State<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  String faceId = 'tmp9i8bbq7c';

  late SimliClient simliClient;
  late DeepgramService deepgramService = DeepgramService();
  GroqService groqService = GroqService();
  CaptionController captionController = CaptionController();
  AudioQueue? audioQueue;
  ConversationMode mode = ConversationMode.chat;
  TextEditingController textEditingController = TextEditingController();
  ValueNotifier<String> status = ValueNotifier("Initializing ...");
  StreamSubscription? streamSubscription;
  String msg = '';

  @override
  void initState() {
    faceId = characterIds[widget.avatarName] ?? faceId;
    deepgramService.setModel(
        model: getTtsModel(faceId) ?? DeepgramTtsModel.asteria);
    simliClient = SimliClient(
        log: log,
        clientConfig: SimliClientConfig(
            apiKey: ApiKeys.simliApiKey,
            faceId: faceId,
            handleSilence: true,
            maxSessionLength: 3600,
            maxIdleTime: 60,
            syncAudio: true,
            audioCheckInterval: Duration(milliseconds: 125),
            silenceThreshold: Duration(milliseconds: 200),
            answerTimeoutTime: Duration(seconds: 20),
            connectionTimeoutTime: Duration(seconds: 120),
            iceGatheringTimeout: Duration(seconds: 60),
            webSocketTimeout: Duration(seconds: 20)));
    audioQueue = AudioQueue(
      sampleRate: 16000,
      sendAudioData: (data) {
        simliClient.sendAudioData(data);
      },
    );
    super.initState();
    deepgramService.onTranscribe = onTranscribe;
    simliClient.isSpeakingNotifier.addListener(
      onSpeakingStatusChange,
    );

    simliClient.onConnection = () {
      status.value = "initializing STT";
      onMicTap();
    };
    simliClient.onFailed = (error) {
      showSnackBar(error.message);
      // Navigator.pop(context);
    };
    listenDeepgramStt();
    Future.delayed(Durations.medium4).then(
      (value) {
        simliClient.start();
      },
    );
  }

  @override
  void dispose() {
    simliClient.isSpeakingNotifier.removeListener(
      onSpeakingStatusChange,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    double avatarSize = 420;
    if (size.width > avatarSize + 32) {
    } else {
      avatarSize = size.width - 32;
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onAnswer("Hello, How are you?");
        },
      ),
      body: Bg(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                    tag: widget.avatarName,
                    child: SimliAvatarView(
                        size: avatarSize,
                        simliClient: simliClient,
                        loadingWidget: Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: SpinKitFadingCircle(
                              color: context.secondary,
                            ),
                          ),
                        ),
                        placeholder: FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          image: AssetImage(
                            'assets/images/${widget.avatarName.toLowerCase()}.png',
                          ),
                        ))),
                const Gap(24),

                CaptionBox(controller: captionController),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: deepgramService.isTranscribing,
                        builder: (context, isTranscribing, child) {
                          return RoundedButton(
                            iconData: Icons.mic,
                            color: Colors.white.withOpacity(0.35),
                            activeColor: context.secondary,
                            iconColor: Colors.black,
                            activeIconColor: Colors.black,
                            onTap: onMicTap,
                            isActive: isTranscribing,
                          );
                        }),
                    const Gap(16),
                    RoundedButton(
                        iconData: Icons.call_end,
                        color: Colors.redAccent,
                        activeColor: Colors.red,
                        onTap: endCall)
                  ],
                ),
                const Gap(16),
                // AmplitudeAnimation(amplitude: deepgramService.amplitude)
                ValueListenableBuilder(
                  valueListenable: status,
                  builder: (context, value, child) {
                    return AnimatedSwitcher(
                      duration: Durations.medium1,
                      child: Text(
                        value,
                        key: ValueKey(value),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  },
                )
              ],
            )),
      ),
    );
  }

  void onMicTap() {
    if (deepgramService.isTranscribing.value) {
      deepgramService.stop();
    } else {
      deepgramService.startTranscribing();
    }
  }

  void listenDeepgramStt() {
    streamSubscription = deepgramService.sttStream.listen(
      (event) {
        if (event.type.toString() == 'SpeechStarted') {
          logInfo("Speech Started");
        } else if (event.type.toString() == 'UtteranceEnd') {
          deepgramService.pause();
          onTranscribe(msg);
          msg = '';
        } else if (event.type.toString() == 'Results') {
          if (event.transcript != null && event.transcript!.isNotEmpty) {
            // msg = event.transcript!;
            // captionController.add(msg);
            logSuccess(
                "${event.type} ${event.transcript} Is Final: ${event.map['is_final']} Speech Final: ${event.map['speech_final']}");
            if (event.map['is_final']) {
              msg = msg + (event.transcript ?? "");
            } else {
              captionController.add(msg + (event.transcript ?? ""));
            }
          }
        }
      },
    );
  }

  Timer? periodic;
  onTranscribe(String captions) async {
    captionController.add(captions);
    status.value = "Thinking...";
    logSuccess("Question: $captions");
    var answer =
        await groqService.sendMsg(text: captions, name: widget.avatarName);
    if (!answer.isSuccessFull) {
      showSnackBar(answer.data);
      endCall();
    } else {
      onAnswer(answer.data);
    }
  }

  void onAnswer(String answer) {
    logSuccess("Answer: $answer");
    var audioStream = deepgramService.ttsStream(answer);
    captionController.addToPipeLine(answer);
    audioQueue?.start(audioStream);
  }

  void endCall() {
    simliClient.close();

    AppRouter.goToAvatarSelection(showFollow: true);
  }

  void sendMessage() {
    if (textEditingController.text.isNotEmpty) {
      onTranscribe(textEditingController.text);
      textEditingController.clear();
      setState(() {});
    }
  }

  bool first = true;
  void onSpeakingStatusChange() {
    if (simliClient.isSpeaking) {
      if (first) {
        status.value = "Listening...";
      } else {
        status.value = "Speaking...";
        captionController.clearPipeline();
      }
    } else {
      if (first) {
        first = false;
      } else {
        deepgramService.resume();
        status.value = "Listening...";
      }
    }
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(AppRouter.context ?? context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

enum ConversationMode {
  chat,
  call,
}

class RoundedButton extends StatefulWidget {
  const RoundedButton(
      {required this.iconData,
      super.key,
      this.onTap,
      this.size = 45,
      this.color,
      this.activeColor,
      this.iconColor,
      this.activeIconColor,
      this.isActive = false});
  final IconData iconData;
  final VoidCallback? onTap;
  final double size;
  final Color? color, iconColor;
  final Color? activeColor, activeIconColor;
  final bool isActive;
  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap?.call();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          setState(() {
            hovered = true;
          });
        },
        onExit: (event) {
          setState(() {
            hovered = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (hovered || widget.isActive
                ? (widget.activeColor ?? context.primary)
                : (widget.color ?? context.primary.withOpacity(0.5))),
          ),
          child: Icon(
            widget.iconData,
            color: hovered || widget.isActive
                ? widget.activeIconColor
                : widget.iconColor,
          ),
        ),
      ),
    );
  }
}

class AudioQueue {
  final int sampleRate;
  final int maxDurationMs;
  final int chunkSize;
  final Function(Uint8List) sendAudioData;

  AudioQueue({
    required this.sampleRate,
    this.maxDurationMs = 1000,
    this.chunkSize = 4000,
    required this.sendAudioData,
  });
  Queue<int> audioQueue = Queue();
  StreamSubscription<Uint8List>? _subscription;
  Timer? periodic;
  void start(Stream<Uint8List> audioStream) {
    _subscription = audioStream.listen(_onData, onDone: _onDone);
    periodic = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      var length = audioQueue.length;
      if (length >= chunkSize) {
        _sendAudioData();
      }
    });
  }

  void _onData(Uint8List data) {
    audioQueue.addAll(data);
  }

  void _onDone() {
    logException("On Done");
    if (audioQueue.isNotEmpty) {
      _sendAudioData(sendAll: true);
    }
    stop();
  }

  void _sendAudioData({bool sendAll = false}) {
    final Uint8List chunk =
        Uint8List.fromList(audioQueue.toList().take(4000).toList());
    sendAudioData(chunk);
    // logSuccess("Data Sent: ${chunk.length}");
    int i = 0;
    int l = chunk.length;
    while (i < l) {
      audioQueue.removeFirst();
      i++;
    }
    if (sendAll && audioQueue.isNotEmpty) {
      _sendAudioData(sendAll: true);
    }
  }

  void stop() {
    _subscription?.cancel();
    periodic?.cancel();
  }
}
