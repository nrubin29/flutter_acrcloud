# flutter_acrcloud

A Flutter plugin for the ACRCloud music recognition API.
This is a third-party plugin; there is no relation between the developer and ACRCloud.

**Note**: I built this plugin to support [a personal project](https://github.com/nrubin29/finale).
As such, it is very bare bones and potentially buggy.
If you encounter a bug or need a feature added, you can open an issue or, better yet, fix it yourself and submit a PR.

## Setup

In order to get access to the microphone, you have to explicitly list the required permission in your iOS and Android apps.

### iOS

1. Open `ios/Runner/Info.plist`.
2. Add the following lines somewhere inside of the `<dict>`:

   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>Recognize the music around you</string>
   ```

3. You can replace the `<string>` with whatever message you want. This message will be displayed in the alert that asks the user to grant permission to access to the microphone.

### Android

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following line inside of the `<manifest>` and above the `<application>`:

   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   ```

## Usage

Consult the `example` app for a real-world example.

1. Call `ACRCloud.setUp()` to provide your API key, API secret, and preferred host. `setUp()` takes an instance of `ACRCloudConfig`.
2. When you want to recognize a song, call `ACRCloud.startSession()` to start a recording session. You will get an instance of `ACRCloudSession` that you can use to interact with the session.
3. To get the current volume, you can use the `volume` property of `ACRCloudSession`. This is a `Stream` that is updated every time a new volume value is recoded.
4. To cancel a session, just call `cancel()` on the session.
5. To get the result of a session, you can `await` the `result` property of the session. If the result is `null`, then the request was cancelled. Otherwise, you'll get an instance of `ACRCloudResponse` that contains all the information.
