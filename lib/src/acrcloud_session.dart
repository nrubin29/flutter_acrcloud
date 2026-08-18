part of 'acrcloud.dart';

/// A single recognition session.
///
/// Create one with `ACRCloud.instance.startSession()`. A session is
/// single-use: once [result] completes, start a new session to recognize
/// again.
final class ACRCloudSession {
  /// The native session identifier. Events from other sessions are ignored.
  final int id;

  final AcrCloudHostApi _api;

  /// How long to wait for a result after [stopAndRecognize] before giving up.
  final Duration _resultTimeout;

  final _result = Completer<ACRCloudResult>();
  final _volume = StreamController<double>.broadcast();

  var _finishing = false;
  Timer? _watchdog;

  ACRCloudSession._(this.id, this._api, this._resultTimeout);

  /// The microphone level while recording.
  ///
  /// This is a broadcast stream and does **not** buffer, so listen as soon as
  /// `startSession()` returns; readings emitted earlier are dropped. Not
  /// listening at all is safe.
  ///
  /// Closes when the session ends. The scale is platform-defined and is **not**
  /// comparable between Android and iOS, so use it for relative feedback only.
  Stream<double> get volume => _volume.stream;

  /// Completes exactly once with the outcome of this session.
  ///
  /// Never throws — failures arrive as [ACRCloudFailure].
  Future<ACRCloudResult> get result => _result.future;

  /// Whether this session is still running.
  bool get isActive => !_result.isCompleted;

  /// Aborts recording. [result] completes with [ACRCloudCancelled].
  ///
  /// Does nothing if the session already finished. Works even after
  /// [stopAndRecognize], so a recognition awaiting a result can still be
  /// abandoned.
  Future<void> cancel() async {
    if (!isActive) return;
    _finishing = true;

    // Complete first. Cancelling is a local decision, so no native failure,
    // hang, or dropped event can leave [result] hanging.
    _complete(const ACRCloudCancelled());

    try {
      await _api.cancelRecognition(id);
    } on Object {
      // The session is over either way; a failure to tell the native side is
      // not worth surfacing to the caller.
    }
  }

  /// Stops recording early and recognizes whatever was captured so far.
  ///
  /// [result] completes normally with a match, a no-match, or a failure.
  Future<void> stopAndRecognize() async {
    if (!isActive || _finishing) return;
    _finishing = true;

    // The result arrives as an event, so bound the wait. Without this a native
    // stall would leave [result] hanging forever.
    _watchdog = Timer(_resultTimeout, () {
      _complete(
        ACRCloudFailure(
          exception: ACRCloudPlatformException(
            code: 'RECOGNITION_TIMEOUT',
            message:
                'No result arrived within ${_resultTimeout.inSeconds} seconds.',
          ),
        ),
      );
    });

    try {
      await _api.stopAndRecognize(id);
    } on Object catch (e) {
      _complete(
        ACRCloudFailure(
          exception: ACRCloudPlatformException(
            code: 'STOP_FAILED',
            message: '$e',
          ),
        ),
      );
    }
  }

  /// Completes this session. Ignored if it already completed.
  void _complete(ACRCloudResult result) {
    if (_result.isCompleted) return;

    _watchdog?.cancel();
    _watchdog = null;

    _result.complete(result);
    unawaited(_volume.close());
  }

  /// Adds a volume reading. Ignored once the session has finished.
  void _addVolume(double value) {
    if (_volume.isClosed) return;
    _volume.add(value);
  }
}
