## 2.0.0

This is a rewrite on Flutter 3.47 with an upgraded iOS SDK and a modernized API.

### Breaking changes

* **`ACRCloud` is now instance-based.** Use `ACRCloud.instance.configure()` instead of the static `ACRCloud.setUp()`, and `await ACRCloud.instance.startSession()`.
* **`ACRCloudConfig` takes named parameters** instead of positional ones.
* **`session.result` returns a sealed `ACRCloudResult`** instead of `ACRCloudResponse?`. Switch over `ACRCloudRecognized`, `ACRCloudNoMatch`, `ACRCloudCancelled`, and `ACRCloudFailure`. A `null` result no longer doubles as "cancelled", and failures are no longer silent.
* **`volumeStream` is now `volume`.**
* **`cancel()` really cancels.** It previously called the Android SDK's `stopRecordToRecognize()`, which stopped recording and then recognized anyway. Use the new `stopAndRecognize()` for the old behavior.
* **Most `ACRCloudResponseMusicItem` fields are nullable.** ACRCloud omits `album`, `release_date`, `score`, and the duration fields for some matches, which used to throw during parsing. Only `acrId` and `title` are guaranteed.
* **Errors throw `ACRCloudException`** subclasses instead of `StateError`.
* Minimum Flutter 3.47.0, minimum iOS 15.0, minimum Android SDK 24.

### Added

* `stopAndRecognize()` stops recording early and recognizes the captured audio.
* `requestMicrophonePermission()` exposes the permission state, including whether a denial is permanent.
* Swift Package Manager support, alongside the existing CocoaPods support.
* The plugin declares `RECORD_AUDIO` and `INTERNET` itself, so apps no longer have to.
* R8 keep rules ship with the plugin, so release builds no longer risk `UnsatisfiedLinkError` from the SDK's JNI methods.
* A privacy manifest declaring audio data collection.

### Changed

* Upgraded the ACRCloud iOS SDK from v1.6.2.1 to **v1.7.0.2**. The old build shipped `armv7` and `i386` slices that modern Xcode rejects; the new one is an xcframework with a proper arm64 simulator slice.
* Replaced the hand-written method channel with [Pigeon](https://pub.dev/packages/pigeon) codegen.
* Removed the Objective-C shim, bridging header, and hand-copied SDK headers on iOS.

### Fixed

* **A session always reaches a terminal result.** After `stopAndRecognize()`, the session waits for a native event, and `cancel()` used to be a no-op in that state. If the event never arrived — a silent SDK stall, or `dispose()` or `configure()` releasing the native client mid-recognition — `session.result` hung forever, `session.volume` never closed, and the stale `activeSession` blocked every later `startSession()`. `cancel()` now completes the result before notifying the native side, and a watchdog fails the session if no event arrives within the request timeout.
* **A broken event stream ends the active session.** An error on the channel was an uncaught async error that also left the session hanging, and a closed stream was silent. Both now complete the result as `ACRCloudFailure`.
* **[Android]** Requesting the permission with no attached activity no longer crashes with a null pointer dereference.
* **[Android]** A denied microphone permission is now honored. It was previously recorded and then ignored.
* **[Android]** Calling `startSession()` before configuring no longer throws `UninitializedPropertyAccessException`.
* **[Android]** The native client is released when the engine detaches. It previously leaked.
* **[Android]** The permission listener is removed when the activity detaches, fixing a leak and duplicate callbacks after a configuration change.
* **[Android]** A failed SDK initialization is reported instead of surfacing later as an unrelated crash.
* **[iOS]** Malformed arguments and calls before configuration no longer crash on force-unwraps.
* **[iOS]** The podspec had a Ruby syntax error from an unescaped apostrophe, and asked for the long-removed `libstdc++`.
* **[iOS]** Dropped `VALID_ARCHS = x86_64`, which broke Apple Silicon simulators.
* Both platforms now report the same error codes instead of Android erroring while iOS silently returned `nil`.
* Events are emitted on the main thread rather than relying on the SDK's own dispatch.

## 1.0.0

* Updated Android libraries to support 16 KB page sizes.

## 0.2.2

* Updated Gradle files.

## 0.2.1

* Bumped Kotlin and Gradle versions.

## 0.2.0

* `ACRCloudResponse` now includes Custom Files metadata if relevant. Thanks, MichaelCadavillo!

## 0.1.6

* [Android] Fixed compilation error for Flutter 3.
* [Android] Cleaned up deprecated code.

## 0.1.5

* [iOS] Set `ENABLE_BITCODE` to `NO` to resolve potential build issues.

## 0.1.4

* Updated ACRCloud SDK to v1.6.2.1
* This should also fix issues with running apps on the iOS simulator.

## 0.1.3

* **BREAKING**: Renamed `volume` to `volumeStream`. It is now just a normal `Stream` instead of a `BehaviorSubject`.
* Removed dependency on `rxdart`.
* Upgraded dependencies.

## 0.1.2

* Made all JSON classes const.
* Upgraded dependencies.

## 0.1.1

* **BREAKING**: Refactored to be a proper library. Now, you just need to `import 'package:flutter_acrcloud/flutter_acrcloud.dart'`.
* Upgraded dependencies.

## 0.1.0

* Added null safety.

## 0.0.2

* Upgraded dependencies.
* Upgraded ACRCloud iOS SDK to v1.6.1.7.

## 0.0.1

* Initial release!
