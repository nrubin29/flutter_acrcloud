library flutter_acrcloud;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_acrcloud/src/acrcloud_response.dart';
import 'package:rxdart/rxdart.dart';

/// A configuration object with the values necessary to access the ACRCloud API.
class ACRCloudConfig {
  final String accessKey;
  final String accessSecret;
  final String host;

  const ACRCloudConfig(this.accessKey, this.accessSecret, this.host);
}

/// A recording session.
class ACRCloudSession {
  final BehaviorSubject<ACRCloudResponse?> _result;

  /// A Stream of volume values.
  final BehaviorSubject<double> volume;

  /// A Future which resolves to null if the session is [cancel]led, or an
  /// [ACRCloudResponse] otherwise.
  late final Future<ACRCloudResponse?> result;

  ACRCloudSession()
      : _result = BehaviorSubject<ACRCloudResponse?>(),
        volume = BehaviorSubject<double>() {
    result = _result.first.catchError((_, __) => null,
        test: (error) => error is StateError && error.message == 'No element');
  }

  /// Cancel this session.
  void cancel() {
    ACRCloud._channel.invokeMethod('cancel');
    dispose();
  }

  void dispose() {
    volume.close();
    _result.close();
  }
}

/// The entry point for interacting with ACRCloud.
class ACRCloud {
  static const _channel = MethodChannel('flutter_acrcloud');

  static var isSetUp = false;
  static ACRCloudSession? _session;

  /// Set up ACRCloud according to the [ACRCloudConfig] passed. You should only
  /// call this function once, but subsequent calls will simply be ignored.
  static Future<void> setUp(ACRCloudConfig config) async {
    if (isSetUp) {
      return;
    }

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'volume') {
        _session?.volume.add(call.arguments);
      } else if (call.method == 'result') {
        _session?._result
            .add(ACRCloudResponse.fromJson(json.decode(call.arguments)));
      }
    });

    await _channel.invokeMethod('setUp', {
      'accessKey': config.accessKey,
      'accessSecret': config.accessSecret,
      'host': config.host
    });

    isSetUp = true;
  }

  /// Begin recognizing a track. Returns an [ACRCloudSession] instance that can
  /// be used to control the session.
  static ACRCloudSession startSession() {
    if (!isSetUp) {
      throw StateError(
          'ACRCloud is not set up! You forgot to call ACRCloud.setUp()');
    }

    _session?.dispose();
    _session = ACRCloudSession();
    _channel.invokeMethod('listen');
    return _session!;
  }
}
