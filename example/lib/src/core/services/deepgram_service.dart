import 'dart:async';
import 'dart:typed_data';

import 'package:deepgram_sdk/models/tts_model.dart';
import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:example/src/core/utils/api_keys.dart';
import 'package:example/src/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import 'package:deepgram_sdk/deepgram_sdk.dart' as dpgs;

class DeepgramService {
  DeepgramService(
      {this.apiKey = ApiKeys.deepgramApiKey,
      this.model = DeepgramTtsModel.asteria}) {
    deepgramSdk = dpgs.Deepgram(ApiKeys.deepgramApiKey);

    deepgram = Deepgram(apiKey);
  }
  DeepgramTtsModel model;
  InputDevice? inputDevice;
  late dpgs.Deepgram deepgramSdk;
  Stream<Uint8List>? recordStream;
  StreamController<DeepgramSttResult> sttStreamController =
      StreamController.broadcast();
  Stream<DeepgramSttResult> get sttStream => sttStreamController.stream;
  ValueNotifier<bool> isTranscribing = ValueNotifier(false);
  ValueNotifier<double> amplitude = ValueNotifier(-60);
  StreamSubscription? streamSubscription;
  DeepgramLiveTranscriber? liveTranscriber;
  final record = AudioRecorder();
  var msg = '';
  Deepgram? deepgram;
  late Function(String captions)? onTranscribe;
  late String apiKey;

  List<int> recordedData = [];

  Stream<Uint8List> ttsStream(String text) {
    return deepgramSdk.tts.ttsStream(text, model: model);
  }

  Timer? timer;
  void startTranscribing() async {
    recordStream = await record.startStream(RecordConfig(
        device: inputDevice,
        echoCancel: true,
        noiseSuppress: true,
        autoGain: true,
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        sampleRate: 16000));
    isTranscribing.value = true;
    logInfo("Recording started");

    liveTranscriber =
        deepgram!.createLiveTranscriber(recordStream!, queryParams: {
      "type": "KeepAlive",
      'model': 'nova-2-conversationalai',
      'detect_language': false,
      'language': 'en',
      'encoding': 'linear16',
      'sample_rate': 16000,
      'channels': 1,
      'dictation': true,
      'punctuate': true,
      'filler_words': true,
      'smart_format': true,
      'numerals': true,
      'interim_results': true,
      'vad_events': true,
      'utterance_end_ms': '1000',
      'endpointing': 300
    });
    streamSubscription = liveTranscriber!.stream.listen(
      (event) {
        sttStreamController.add(event);
      },
    );
    await liveTranscriber?.start();
    logInfo("Transcribing started");
    _startAmplitudeListen();
  }

  void stop() {
    _stopAmplitudeListen();
    record.stop();
    liveTranscriber?.close();
    isTranscribing.value = false;
    streamSubscription?.cancel();
  }

  void pause() {
    _stopAmplitudeListen();
    liveTranscriber?.pause(keepAlive: true);
    isTranscribing.value = false;
  }

  void resume() {
    liveTranscriber?.resume();
    isTranscribing.value = true;
    _startAmplitudeListen();
  }

  void _startAmplitudeListen() {
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        record.getAmplitude().then(
          (value) {
            amplitude.value = value.current;
          },
        );
      },
    );
  }

  void _stopAmplitudeListen() {
    timer?.cancel();
  }

  void dispose() {}

  void setModel({required DeepgramTtsModel model}) {
    this.model = model;
  }
}

class AmplitudeAnimation extends StatelessWidget {
  const AmplitudeAnimation({super.key, required this.amplitude});
  final ValueNotifier<double> amplitude;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: amplitude,
        builder: (context, amplitude, child) {
          // Convert amplitude from dBFS to a scale factor (0.0 to 1.0)
          double scaleFactor = (amplitude + 60.0) / 60.0;
          return Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 100.0 * scaleFactor, // Adjust size based on scaleFactor
              height: 100.0 * scaleFactor, // Adjust size based on scaleFactor
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width:
                        75.0 * scaleFactor, // Adjust size based on scaleFactor
                    height:
                        75.0 * scaleFactor, // Adjust size based on scaleFactor
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 50.0 *
                            scaleFactor, // Adjust size based on scaleFactor
                        height: 50.0 *
                            scaleFactor, // Adjust size based on scaleFactor
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )),
              ),
            ),
          );
        });
  }
}
