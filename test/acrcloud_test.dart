import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_acrcloud/src/messages.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records host calls and lets tests script the responses.
class _FakeHostApi extends AcrCloudHostApi {
  _FakeHostApi();

  final calls = <String>[];

  AcrCloudPermissionStatus permission = AcrCloudPermissionStatus.granted;
  int nextSessionId = 1;
  Object? startError;

  @override
  Future<AcrCloudPermissionStatus> requestMicrophonePermission() async {
    calls.add('requestMicrophonePermission');
    return permission;
  }

  @override
  Future<void> configure(AcrCloudConfigMessage config) async {
    calls.add('configure(${config.host},${config.requestTimeoutMs})');
  }

  @override
  Future<int> startRecognition() async {
    calls.add('startRecognition');
    if (startError case final error?) throw error;
    return nextSessionId;
  }

  @override
  Future<void> cancelRecognition(int sessionId) async {
    calls.add('cancelRecognition($sessionId)');
  }

  @override
  Future<void> stopAndRecognize(int sessionId) async {
    calls.add('stopAndRecognize($sessionId)');
  }

  @override
  Future<void> release() async {
    calls.add('release');
  }
}

String _responseJson({
  int code = 0,
  List<Map<String, dynamic>> music = const [],
}) => json.encode({
  'status': {
    'code': code,
    'msg': code == 0 ? 'Success' : 'Error',
    'version': '1.0',
  },
  if (music.isNotEmpty) 'metadata': {'music': music},
});

const _track = {
  'acrid': 'abc123',
  'title': 'Hello',
  'artists': [
    {'name': 'Adele'},
  ],
};

void main() {
  late _FakeHostApi api;
  late StreamController<AcrCloudEvent> events;
  late ACRCloud acrCloud;

  setUp(() {
    api = _FakeHostApi();
    events = StreamController<AcrCloudEvent>.broadcast();
    acrCloud = ACRCloud.forTesting(
      api: api,
      events: ({String instanceName = ''}) => events.stream,
    );
  });

  tearDown(() => events.close());

  Future<ACRCloudSession> configureAndStart() async {
    await acrCloud.configure(
      const ACRCloudConfig(
        accessKey: 'k',
        accessSecret: 's',
        host: 'identify-eu-west-1.acrcloud.com',
      ),
    );
    return acrCloud.startSession();
  }

  group('configure', () {
    test('passes credentials and timeout to the host', () async {
      await acrCloud.configure(
        const ACRCloudConfig(
          accessKey: 'k',
          accessSecret: 's',
          host: 'my-host',
          requestTimeout: Duration(seconds: 5),
        ),
      );

      expect(acrCloud.isConfigured, isTrue);
      expect(api.calls, contains('configure(my-host,5000)'));
    });

    test('throws when the microphone is denied', () async {
      api.permission = AcrCloudPermissionStatus.denied;

      await expectLater(
        acrCloud.configure(
          const ACRCloudConfig(accessKey: 'k', accessSecret: 's', host: 'h'),
        ),
        throwsA(
          isA<ACRCloudPermissionDeniedException>().having(
            (e) => e.permanently,
            'permanently',
            isFalse,
          ),
        ),
      );

      expect(acrCloud.isConfigured, isFalse);
    });

    test('reports a permanent denial distinctly', () async {
      api.permission = AcrCloudPermissionStatus.permanentlyDenied;

      await expectLater(
        acrCloud.configure(
          const ACRCloudConfig(accessKey: 'k', accessSecret: 's', host: 'h'),
        ),
        throwsA(
          isA<ACRCloudPermissionDeniedException>().having(
            (e) => e.permanently,
            'permanently',
            isTrue,
          ),
        ),
      );
    });
  });

  group('startSession', () {
    test('throws before configure', () {
      expect(
        acrCloud.startSession(),
        throwsA(isA<ACRCloudNotConfiguredException>()),
      );
    });

    test('throws while a session is active', () async {
      await configureAndStart();

      await expectLater(
        acrCloud.startSession(),
        throwsA(isA<ACRCloudSessionActiveException>()),
      );
    });

    test('allows a new session once the previous one finished', () async {
      final first = await configureAndStart();
      events.add(
        AcrCloudResultEvent(
          sessionId: first.id,
          resultJson: _responseJson(code: 1001),
        ),
      );
      await first.result;

      api.nextSessionId = 2;
      final second = await acrCloud.startSession();
      expect(second.id, 2);
    });
  });

  group('events', () {
    test('volume reaches the session stream', () async {
      final session = await configureAndStart();
      final volumes = <double>[];
      session.volume.listen(volumes.add);

      events
        ..add(AcrCloudVolumeEvent(sessionId: session.id, volume: 0.25))
        ..add(AcrCloudVolumeEvent(sessionId: session.id, volume: 0.75));
      await pumpEventQueue();

      expect(volumes, [0.25, 0.75]);
    });

    test('events for a stale session are ignored', () async {
      final session = await configureAndStart();
      final volumes = <double>[];
      session.volume.listen(volumes.add);

      events.add(AcrCloudVolumeEvent(sessionId: session.id + 99, volume: 0.5));
      await pumpEventQueue();

      expect(volumes, isEmpty);
      expect(session.isActive, isTrue);
    });

    test('a match completes with ACRCloudRecognized', () async {
      final session = await configureAndStart();
      events.add(
        AcrCloudResultEvent(
          sessionId: session.id,
          resultJson: _responseJson(music: [_track]),
        ),
      );

      final result = await session.result;
      expect(result, isA<ACRCloudRecognized>());
      expect((result as ACRCloudRecognized).music.single.title, 'Hello');
      expect(result.music.single.album, isNull);
    });

    test('code 1001 completes with ACRCloudNoMatch', () async {
      final session = await configureAndStart();
      events.add(
        AcrCloudResultEvent(
          sessionId: session.id,
          resultJson: _responseJson(code: 1001),
        ),
      );

      expect(await session.result, isA<ACRCloudNoMatch>());
    });

    test('code 0 with no metadata completes with ACRCloudNoMatch', () async {
      final session = await configureAndStart();
      events.add(
        AcrCloudResultEvent(sessionId: session.id, resultJson: _responseJson()),
      );

      expect(await session.result, isA<ACRCloudNoMatch>());
    });

    test('a service error completes with ACRCloudFailure', () async {
      final session = await configureAndStart();
      events.add(
        AcrCloudResultEvent(
          sessionId: session.id,
          resultJson: _responseJson(code: 3003),
        ),
      );

      final result = await session.result;
      expect(result, isA<ACRCloudFailure>());
      expect(
        (result as ACRCloudFailure).exception,
        isA<ACRCloudPlatformException>().having(
          (e) => e.code,
          'code',
          'ACRCLOUD_3003',
        ),
      );
    });

    test('malformed JSON completes with ACRCloudFailure', () async {
      final session = await configureAndStart();
      events.add(
        AcrCloudResultEvent(sessionId: session.id, resultJson: 'not json'),
      );

      final result = await session.result;
      expect(result, isA<ACRCloudFailure>());
      expect(
        (result as ACRCloudFailure).exception,
        isA<ACRCloudPlatformException>().having(
          (e) => e.code,
          'code',
          'MALFORMED_RESPONSE',
        ),
      );
    });

    test('a native error completes with ACRCloudFailure', () async {
      final session = await configureAndStart();
      events.add(
        AcrCloudErrorEvent(
          sessionId: session.id,
          code: 'START_FAILED',
          message: 'boom',
        ),
      );

      final result = await session.result;
      expect(result, isA<ACRCloudFailure>());
      expect((result as ACRCloudFailure).exception.message, 'boom');
    });
  });

  group('session lifecycle', () {
    test('cancel completes with ACRCloudCancelled and closes volume', () async {
      final session = await configureAndStart();

      await session.cancel();

      expect(await session.result, isA<ACRCloudCancelled>());
      expect(api.calls, contains('cancelRecognition(${session.id})'));
      await expectLater(session.volume, emitsDone);
    });

    test('cancel is idempotent', () async {
      final session = await configureAndStart();

      await session.cancel();
      await session.cancel();

      expect(
        api.calls.where((c) => c.startsWith('cancelRecognition')).length,
        1,
      );
    });

    test('stopAndRecognize still yields a result', () async {
      final session = await configureAndStart();

      await session.stopAndRecognize();
      expect(api.calls, contains('stopAndRecognize(${session.id})'));
      expect(session.isActive, isTrue);

      events.add(
        AcrCloudResultEvent(
          sessionId: session.id,
          resultJson: _responseJson(music: [_track]),
        ),
      );
      expect(await session.result, isA<ACRCloudRecognized>());
    });

    test('a result after cancel does not overwrite the outcome', () async {
      final session = await configureAndStart();
      await session.cancel();

      events.add(
        AcrCloudResultEvent(
          sessionId: session.id,
          resultJson: _responseJson(music: [_track]),
        ),
      );
      await pumpEventQueue();

      expect(await session.result, isA<ACRCloudCancelled>());
    });

    test('dispose releases the host client', () async {
      await configureAndStart();

      await acrCloud.dispose();

      expect(acrCloud.isConfigured, isFalse);
      expect(acrCloud.activeSession, isNull);
      expect(api.calls, contains('release'));
    });
  });

  group('a session always terminates', () {
    test('cancel works after stopAndRecognize', () async {
      final session = await configureAndStart();

      await session.stopAndRecognize();
      expect(session.isActive, isTrue);

      await session.cancel();

      expect(await session.result, isA<ACRCloudCancelled>());
      await expectLater(session.volume, emitsDone);
    });

    test('dispose during recognition completes the session', () async {
      final session = await configureAndStart();
      await session.stopAndRecognize();

      await acrCloud.dispose();

      expect(await session.result, isA<ACRCloudCancelled>());
      await expectLater(session.volume, emitsDone);
    });

    test('configure during recognition completes the prior session', () async {
      final session = await configureAndStart();
      await session.stopAndRecognize();

      await acrCloud.configure(
        const ACRCloudConfig(accessKey: 'k2', accessSecret: 's2', host: 'h2'),
      );

      expect(await session.result, isA<ACRCloudCancelled>());
      expect(acrCloud.activeSession, isNull);
    });

    test('a stranded session does not block the next one', () async {
      final first = await configureAndStart();
      await first.stopAndRecognize();
      await first.cancel();

      api.nextSessionId = 2;
      final second = await acrCloud.startSession();

      expect(second.id, 2);
      expect(second.isActive, isTrue);
    });

    test('an event stream error completes the session', () async {
      final session = await configureAndStart();

      events.addError(StateError('channel died'));
      await pumpEventQueue();

      final result = await session.result;
      expect(
        (result as ACRCloudFailure).exception,
        isA<ACRCloudPlatformException>().having(
          (e) => e.code,
          'code',
          'EVENT_CHANNEL_ERROR',
        ),
      );
    });

    test('an event stream close completes the session', () async {
      final session = await configureAndStart();

      await events.close();
      await pumpEventQueue();

      final result = await session.result;
      expect(
        (result as ACRCloudFailure).exception,
        isA<ACRCloudPlatformException>().having(
          (e) => e.code,
          'code',
          'EVENT_STREAM_CLOSED',
        ),
      );
    });

    test('a silent native stall times out', () {
      fakeAsync((async) {
        late ACRCloudSession session;
        configureAndStart().then((s) {
          session = s;
          session.stopAndRecognize();
        });
        async.flushMicrotasks();

        ACRCloudResult? outcome;
        session.result.then((r) => outcome = r);

        // The default 10s request timeout plus the 5s margin.
        async.elapse(const Duration(seconds: 14));
        async.flushMicrotasks();
        expect(outcome, isNull, reason: 'must not fire before the deadline');

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(
          (outcome as ACRCloudFailure).exception,
          isA<ACRCloudPlatformException>().having(
            (e) => e.code,
            'code',
            'RECOGNITION_TIMEOUT',
          ),
        );
      });
    });
  });
}
