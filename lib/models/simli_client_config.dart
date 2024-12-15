import 'package:simli_client/simli_client.dart';

/// This will configuration for the [SimliClient]
///
/// [apiKey] is the key used for authenticating API requests.
/// [faceId] identifies the face to use for the session.
/// [handleSilence] is optional and determines whether
/// silence handling is enabled.
class SimliClientConfig {
  /// Constructs the [SimliClientConfig] with the necessary values.
  SimliClientConfig({
    required this.apiKey,
    required this.faceId,
    required this.handleSilence,
    required this.maxSessionLength,
    required this.maxIdleTime,
    required this.syncAudio,
    this.retryDelay = const Duration(milliseconds: 1500),
    this.connectionTimeoutTime = const Duration(seconds: 60),
    this.requestTimeout = const Duration(seconds: 30),
    this.audioCheckInterval = const Duration(milliseconds: 100),
    this.silenceThreshold = const Duration(
      milliseconds: 1250,
    ),
    this.iceGatheringTimeout = const Duration(seconds: 10),
    this.maxRetryAttempts = 3, // default value for maxRetryAttempts
    this.webSocketTimeout =
        const Duration(seconds: 20), // added webSocketTimeout
    this.answerTimeoutTime = const Duration(seconds: 10),
    this.videoReferenceUrl =
        'https://storage.googleapis.com/charactervideos/5514e24d-6086-46a3-ace4-6a7264e5cb7c/5514e24d-6086-46a3-ace4-6a7264e5cb7c.mp4', // added videoReferenceUrl
    this.isJPG = true, // added isJPG
  });

  /// Factory constructor for creating an instance from JSON if needed.
  factory SimliClientConfig.fromJson(Map<String, dynamic> json) {
    return SimliClientConfig(
      apiKey: json['apiKey'] as String,
      faceId: json['faceID'] as String,
      handleSilence: json['handleSilence'] as bool,
      maxSessionLength: json['maxSessionLength'] as int,
      maxIdleTime: json['maxIdleTime'] as int,
      syncAudio: json['syncAudio'] as bool,
      videoReferenceUrl:
          json['videoReferenceUrl'] as String, // added videoReferenceUrl
      isJPG: json['isJPG'] as bool? ?? true, // added isJPG
    );
  }

  /// The API key for authentication.
  final String apiKey;

  /// The Face ID associated with the client.
  final String faceId;

  /// Whether silence should be handled by the client.
  final bool handleSilence;

  /// Maximum session length allowed.
  final int maxSessionLength;

  /// Maximum idle time allowed.
  final int maxIdleTime;

  /// Whether audio should be synchronized.
  final bool syncAudio;

  /// Duration for retry delay.
  /// This duration specifies how long the system should wait before retrying
  /// a failed operation.
  final Duration retryDelay;

  /// Duration for connection timeout.
  /// Specifies the maximum time to wait while trying to establish
  /// a connection before giving up.
  final Duration connectionTimeoutTime;

  /// Duration for request timeout.
  /// Defines the maximum time to wait for a request to complete successfully.
  final Duration requestTimeout;

  /// Duration for audio check interval.
  /// This interval is used to determine how frequently
  /// the audio status should be checked.
  final Duration audioCheckInterval;

  /// Duration for silence threshold.
  /// Sets the duration beyond which silence is considered
  /// significant enough to take an action.
  final Duration silenceThreshold;

  /// Duration for ICE gathering timeout.
  /// Defines the maximum time to wait for ICE gathering
  /// before declaring a failure.
  final Duration iceGatheringTimeout;

  /// Max number of retry attempts for API requests.
  final int maxRetryAttempts;

  /// Duration for WebSocket timeout.
  /// The time period to wait for WebSocket before timing out.
  final Duration webSocketTimeout;

  /// Duration for answer timeout.
  /// The maximum time to wait for an answer before timing out.
  final Duration answerTimeoutTime;

  /// Video reference URL for the session.
  final String videoReferenceUrl;

  /// Indicates if the file format is JPG.
  final bool isJPG;

  /// Converts the [SimliClientConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'faceId': faceId,
      'handleSilence': handleSilence,
      'maxSessionLength': maxSessionLength,
      'maxIdleTime': maxIdleTime,
      'syncAudio': syncAudio,
      'videoReferenceUrl': videoReferenceUrl, // added videoReferenceUrl
      'isJPG': isJPG, // added isJPG
    };
  }
}
