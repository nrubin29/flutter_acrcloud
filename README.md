# flutter_acrcloud

A Flutter plugin for the ACRCloud music recognition API.
This is a third-party plugin; there is no relation between the developer and ACRCloud.

**Note**: I built this plugin to support [a personal project](https://github.com/nrubin29/finale).
As such, it is very bare bones and potentially buggy.
If you encounter a bug or need a feature added, you can open an issue or, better yet, fix it yourself and submit a PR.

Bundled SDKs: **ACRCloud Android 1.3.33** and **ACRCloud iOS 1.7.0.2**.

## Setup

### Android

Nothing to do. The plugin declares `RECORD_AUDIO` and `INTERNET` in its own manifest, so they merge into your app automatically.

### iOS

Apple requires the usage description to live in your app's own `Info.plist`.

1. Open `ios/Runner/Info.plist`.
2. Add the following lines inside the `<dict>`:

   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>Recognize the music around you</string>
   ```

3. Replace the `<string>` with whatever you want. iOS shows this message in the microphone permission prompt.

The plugin supports both Swift Package Manager and CocoaPods. SPM is used by default on Flutter 3.44 and later.

## Usage

Consult the `example` app for a real-world example.

### 1. Configure

Call `configure()` once with your credentials. It requests the microphone permission and then creates the native client.

```dart
import 'package:flutter_acrcloud/flutter_acrcloud.dart';

try {
  await ACRCloud.instance.configure(const ACRCloudConfig(
    accessKey: '...',
    accessSecret: '...',
    host: 'identify-eu-west-1.acrcloud.com',
  ));
} on ACRCloudPermissionDeniedException catch (e) {
  // e.permanently tells you whether asking again is pointless.
}
```

### 2. Start a session

```dart
final session = await ACRCloud.instance.startSession();
```

### 3. Watch the volume

`session.volume` is a broadcast `Stream<double>` that closes when the session ends. The scale is platform-defined and is **not** comparable between Android and iOS, so use it for relative feedback only.

```dart
session.volume.listen((level) => setState(() => _level = level));
```

### 4. Stop early or cancel

- **`session.cancel()`** aborts. The result becomes `ACRCloudCancelled`.
- **`session.stopAndRecognize()`** stops recording and recognizes what it captured so far.

### 5. Await the result

`session.result` always completes with a value and never throws. Handle every case with an exhaustive switch:

```dart
switch (await session.result) {
  case ACRCloudRecognized(:final music, :final customFiles):
    print(music.firstOrNull?.title);
  case ACRCloudNoMatch():
    print('Nothing matched.');
  case ACRCloudCancelled():
    break;
  case ACRCloudFailure(:final exception):
    print('Recognition failed: ${exception.message}');
}
```

`session.volume` is a broadcast stream and does not buffer, so listen as soon as
`startSession()` returns. Readings emitted before you listen are dropped. Not
listening at all is safe.

### Disposing

`ACRCloud.instance.dispose()` releases the native client and cancels any active
session. It is optional: the plugin already releases the client when the Flutter
engine detaches, so a normal single-engine app never has to call it.

Call it when you want the microphone back before the app exits — leaving a
recognition screen, for example — or when you host Flutter inside a larger app.
Call `configure()` again before the next `startSession()`.

## Migrating from 1.x

| 1.x | 2.x |
| --- | --- |
| `ACRCloud.setUp(config)` | `await ACRCloud.instance.configure(config)` |
| `ACRCloud.startSession()` | `await ACRCloud.instance.startSession()` |
| `ACRCloudConfig(key, secret, host)` | `ACRCloudConfig(accessKey: ..., accessSecret: ..., host: ...)` |
| `ACRCloud.isSetUp` | `ACRCloud.instance.isConfigured` |
| `session.volumeStream` | `session.volume` |
| `Future<ACRCloudResponse?> result` | `Future<ACRCloudResult> result` (sealed) |
| `result == null` means cancelled | `case ACRCloudCancelled()` |
| `session.dispose()` | `ACRCloud.instance.dispose()` |
| App declares `RECORD_AUDIO` | The plugin declares it |

Two behavior changes worth knowing:

- **`cancel()` really cancels now.** In 1.x it called the Android SDK's `stopRecordToRecognize()`, which stopped recording and then recognized anyway. If you relied on that, use `stopAndRecognize()`.
- **Most `ACRCloudResponseMusicItem` fields are nullable.** ACRCloud omits `album`, `release_date`, and the numeric fields for some matches, which used to throw during parsing. Only `acrId` and `title` are guaranteed.
