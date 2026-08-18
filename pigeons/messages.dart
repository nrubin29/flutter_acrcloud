import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartPackageName: 'flutter_acrcloud',
    kotlinOut:
        'android/src/main/kotlin/com/noahzrubin/flutter_acrcloud/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.noahzrubin.flutter_acrcloud',
      errorClassName: 'AcrCloudFlutterError',
    ),
    swiftOut: 'ios/flutter_acrcloud/Sources/flutter_acrcloud/Messages.g.swift',
    swiftOptions: SwiftOptions(errorClassName: 'AcrCloudPigeonError'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Whether the host granted access to the microphone.
enum AcrCloudPermissionStatus { granted, denied, permanentlyDenied }

/// Credentials and tuning passed to the native ACRCloud client.
class AcrCloudConfigMessage {
  AcrCloudConfigMessage({
    required this.accessKey,
    required this.accessSecret,
    required this.host,
    required this.requestTimeoutMs,
    required this.useHttps,
  });

  final String accessKey;
  final String accessSecret;
  final String host;
  final int requestTimeoutMs;
  final bool useHttps;
}

/// Something the native side reported during a recognition session.
///
/// Every event carries the [sessionId] it belongs to so that Dart can drop
/// events left over from a session that has already finished.
sealed class AcrCloudEvent {}

/// The microphone level changed.
class AcrCloudVolumeEvent extends AcrCloudEvent {
  AcrCloudVolumeEvent(this.sessionId, this.volume);

  final int sessionId;
  final double volume;
}

/// Recognition finished. [resultJson] is the verbatim ACRCloud response body.
class AcrCloudResultEvent extends AcrCloudEvent {
  AcrCloudResultEvent(this.sessionId, this.resultJson);

  final int sessionId;
  final String resultJson;
}

/// Recognition failed before it could produce a response body.
class AcrCloudErrorEvent extends AcrCloudEvent {
  AcrCloudErrorEvent(this.sessionId, this.code, this.message);

  final int sessionId;
  final String code;
  final String? message;
}

@HostApi()
abstract class AcrCloudHostApi {
  /// Prompts for microphone access if the user has not decided yet.
  @async
  AcrCloudPermissionStatus requestMicrophonePermission();

  /// Creates the native client. Replaces any existing one.
  @async
  void configure(AcrCloudConfigMessage config);

  /// Starts recording and recognizing. Returns the new session id.
  @async
  int startRecognition();

  /// Aborts recording. No result event follows.
  @async
  void cancelRecognition(int sessionId);

  /// Stops recording early and recognizes the audio captured so far.
  @async
  void stopAndRecognize(int sessionId);

  /// Releases the native client.
  @async
  void release();
}

@EventChannelApi()
abstract class AcrCloudEventApi {
  AcrCloudEvent recognitionEvents();
}
