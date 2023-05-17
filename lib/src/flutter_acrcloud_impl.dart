library flutter_acrcloud;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_acrcloud/src/acrcloud_response.dart';

/// A configuration object with the values necessary to access the ACRCloud API.
class ACRCloudConfig {
  final String accessKey;
  final String accessSecret;
  final String host;

  const ACRCloudConfig(this.accessKey, this.accessSecret, this.host);
}

/// A recording session.
class ACRCloudSession {
  final _result = Completer<ACRCloudResponse?>();
  final _volume = StreamController<double>();

  /// A [Future] which resolves to `null` if the session is [cancel]led, or an
  /// [ACRCloudResponse] otherwise.
  Future<ACRCloudResponse?> get result => _result.future;

  /// A [Stream] of volume values.
  Stream<double> get volumeStream => _volume.stream;

  ACRCloudSession._();

  /// Cancel this session.
  void cancel() {
    ACRCloud._channel.invokeMethod('cancel');
    dispose();
  }

  void dispose() {
    _volume.close();

    if (!_result.isCompleted) {
      _result.complete();
    }
  }
}

/// The entry point for interacting with ACRCloud.
class ACRCloud {
  static const _channel = MethodChannel('flutter_acrcloud');

  static var _isSetUp = false;
  static ACRCloudSession? _session;

  /// Whether the client has been set up.
  ///
  /// You must call [setUp] before calling [startSession].
  static bool get isSetUp => _isSetUp;

  const ACRCloud._();

  /// Set up ACRCloud according to the [ACRCloudConfig] passed.
  ///
  /// You only need to call this function once; subsequent calls will be
  /// ignored.
  static Future<void> setUp(ACRCloudConfig config) async {
    if (_isSetUp) {
      return;
    }

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'volume') {
        _session?._volume.add(call.arguments);
      } else if (call.method == 'result') {
        _session?._result
            .complete(ACRCloudResponse.fromJson(json.decode(call.arguments)));
      }
    });

    await _channel.invokeMethod('setUp', {
      'accessKey': config.accessKey,
      'accessSecret': config.accessSecret,
      'host': config.host
    });

    _isSetUp = true;
  }

  /// Begin recognizing a track.
  ///
  /// Returns an [ACRCloudSession] instance that can be used to control the
  /// session.
  static ACRCloudSession startSession() {
    if (!_isSetUp) {
      throw StateError(
          'ACRCloud is not set up! You forgot to call ACRCloud.setUp()');
    }

    _session?.dispose();
    _session = ACRCloudSession._();
    _channel.invokeMethod('listen');
    return _session!;
  }
}
