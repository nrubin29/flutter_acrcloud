import 'dart:async';

import 'package:flutter/foundation.dart';

import 'acrcloud_exception.dart';
import 'acrcloud_result.dart';
import 'messages.g.dart';

part 'acrcloud_session.dart';

/// The credentials and tuning needed to talk to ACRCloud.
///
/// Get these from your project in the ACRCloud console.
@immutable
final class ACRCloudConfig {
  final String accessKey;
  final String accessSecret;

  /// The identification endpoint, for example
  /// `identify-eu-west-1.acrcloud.com`.
  final String host;

  /// How long a single recognition request may take.
  final Duration requestTimeout;

  /// Whether to talk to ACRCloud over HTTPS. Leave this on.
  final bool useHttps;

  const ACRCloudConfig({
    required this.accessKey,
    required this.accessSecret,
    required this.host,
    this.requestTimeout = const Duration(seconds: 10),
    this.useHttps = true,
  });
}

/// The entry point for interacting with ACRCloud.
///
/// Use [ACRCloud.instance] unless you are writing a test.
///
/// ```dart
/// await ACRCloud.instance.configure(const ACRCloudConfig(
///   accessKey: '...',
///   accessSecret: '...',
///   host: 'identify-eu-west-1.acrcloud.com',
/// ));
///
/// final session = await ACRCloud.instance.startSession();
/// session.volume.listen((v) => setState(() => _level = v));
/// final result = await session.result;
/// ```
final class ACRCloud {
  /// The shared instance. The device has one microphone, so there is one
  /// client.
  static final ACRCloud instance = ACRCloud._(
    AcrCloudHostApi(),
    recognitionEvents,
  );

  final AcrCloudHostApi _api;
  final Stream<AcrCloudEvent> Function({String instanceName}) _events;

  StreamSubscription<AcrCloudEvent>? _subscription;
  ACRCloudSession? _session;
  var _isConfigured = false;

  /// The timeout from the most recent [configure], handed to each session.
  var _requestTimeout = const Duration(seconds: 10);

  ACRCloud._(this._api, this._events);

  /// Builds an instance backed by fakes.
  @visibleForTesting
  factory ACRCloud.forTesting({
    required AcrCloudHostApi api,
    required Stream<AcrCloudEvent> Function({String instanceName}) events,
  }) => ACRCloud._(api, events);

  /// Whether [configure] has completed successfully.
  bool get isConfigured => _isConfigured;

  /// The session currently running, if any.
  ACRCloudSession? get activeSession =>
      _session?.isActive ?? false ? _session : null;

  /// Prompts for microphone access if the user has not decided yet.
  ///
  /// [configure] calls this for you, so you only need it if you want to ask
  /// at a different moment.
  Future<AcrCloudPermissionStatus> requestMicrophonePermission() =>
      _api.requestMicrophonePermission();

  /// Sets up the native client.
  ///
  /// Requests the microphone permission first, then creates the client. Safe
  /// to call again to swap credentials; doing so cancels any active session.
  ///
  /// Throws [ACRCloudPermissionDeniedException] if the user refuses the
  /// microphone, and [ACRCloudPlatformException] if the native client fails to
  /// initialize.
  Future<void> configure(ACRCloudConfig config) async {
    final permission = await _api.requestMicrophonePermission();

    if (permission != AcrCloudPermissionStatus.granted) {
      throw ACRCloudPermissionDeniedException(
        permanently: permission == AcrCloudPermissionStatus.permanentlyDenied,
      );
    }

    await _session?.cancel();

    // Subscribe before configuring so no event can be missed.
    _subscription ??= _events().listen(
      _onEvent,
      onError: (Object e, StackTrace _) =>
          _failActiveSession('EVENT_CHANNEL_ERROR', '$e'),
      onDone: () => _failActiveSession(
        'EVENT_STREAM_CLOSED',
        'The native event stream closed before a result arrived.',
      ),
    );

    _requestTimeout = config.requestTimeout;

    await _api.configure(
      AcrCloudConfigMessage(
        accessKey: config.accessKey,
        accessSecret: config.accessSecret,
        host: config.host,
        requestTimeoutMs: config.requestTimeout.inMilliseconds,
        useHttps: config.useHttps,
      ),
    );

    _isConfigured = true;
  }

  /// Starts recognizing a track.
  ///
  /// Throws [ACRCloudNotConfiguredException] if [configure] has not completed,
  /// and [ACRCloudSessionActiveException] if a session is already running.
  Future<ACRCloudSession> startSession() async {
    if (!_isConfigured) {
      throw const ACRCloudNotConfiguredException();
    }

    if (activeSession != null) {
      throw const ACRCloudSessionActiveException();
    }

    final id = await _api.startRecognition();

    // The native SDK enforces `requestTimeout` itself, so give it a margin
    // before the Dart-side watchdog steps in.
    final session = ACRCloudSession._(
      id,
      _api,
      _requestTimeout + const Duration(seconds: 5),
    );

    _session = session;
    return session;
  }

  /// Releases the native client and stops listening for events.
  ///
  /// Call [configure] again before starting another session.
  Future<void> dispose() async {
    await _session?.cancel();
    _session = null;

    await _subscription?.cancel();
    _subscription = null;

    _isConfigured = false;
    await _api.release();
  }

  /// Ends the active session with a failure.
  ///
  /// Used when the event stream breaks, since no result can arrive after that.
  void _failActiveSession(String code, String message) {
    _session?._complete(
      ACRCloudFailure(
        exception: ACRCloudPlatformException(code: code, message: message),
      ),
    );
  }

  void _onEvent(AcrCloudEvent event) {
    final session = _session;
    if (session == null) return;

    switch (event) {
      case AcrCloudVolumeEvent(:final sessionId, :final volume):
        if (sessionId == session.id) session._addVolume(volume);

      case AcrCloudResultEvent(:final sessionId, :final resultJson):
        if (sessionId == session.id) {
          session._complete(parseACRCloudResult(resultJson));
        }

      case AcrCloudErrorEvent(:final sessionId, :final code, :final message):
        if (sessionId == session.id) {
          session._complete(
            ACRCloudFailure(
              exception: ACRCloudPlatformException(
                code: code,
                message: message ?? 'The ACRCloud SDK reported an error.',
              ),
            ),
          );
        }
    }
  }
}
