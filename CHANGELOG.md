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
