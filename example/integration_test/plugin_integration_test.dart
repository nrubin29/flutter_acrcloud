// Integration tests run on a real device or emulator.
//
// Run with: flutter test integration_test
//
// These exercise the Pigeon host API and the event channel end to end. They do
// not assert a real recognition, which would need network access and audio.

import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await ACRCloud.instance.dispose();
  });

  testWidgets('reports a microphone permission status', (tester) async {
    final status = await ACRCloud.instance.requestMicrophonePermission();
    expect(status, isA<AcrCloudPermissionStatus>());
  });

  testWidgets('starting a session before configure throws', (tester) async {
    await expectLater(
      ACRCloud.instance.startSession(),
      throwsA(isA<ACRCloudNotConfiguredException>()),
    );
  });

  testWidgets('configure, start, and cancel round-trip through native', (
    tester,
  ) async {
    final permission = await ACRCloud.instance.requestMicrophonePermission();

    if (permission != AcrCloudPermissionStatus.granted) {
      // On CI, pre-grant with:
      //   adb shell pm grant <appId> android.permission.RECORD_AUDIO
      await expectLater(
        ACRCloud.instance.configure(_config),
        throwsA(isA<ACRCloudPermissionDeniedException>()),
      );
      return;
    }

    await ACRCloud.instance.configure(_config);
    expect(ACRCloud.instance.isConfigured, isTrue);

    final session = await ACRCloud.instance.startSession();
    expect(session.isActive, isTrue);
    expect(ACRCloud.instance.activeSession, same(session));

    // A second session while one is active is rejected.
    await expectLater(
      ACRCloud.instance.startSession(),
      throwsA(isA<ACRCloudSessionActiveException>()),
    );

    await session.cancel();

    expect(await session.result, isA<ACRCloudCancelled>());
    expect(session.isActive, isFalse);
    await expectLater(session.volume, emitsDone);
  });
}

const _config = ACRCloudConfig(
  accessKey: 'integration-test',
  accessSecret: 'integration-test',
  host: 'identify-eu-west-1.acrcloud.com',
);
