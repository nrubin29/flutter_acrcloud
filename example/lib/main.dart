import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';

/// Supply these with:
/// flutter run --dart-define-from-file=env.json
///
/// See env-sample.json for the expected shape.
const accessKey = String.fromEnvironment('ACR_ACCESS_KEY');
const accessSecret = String.fromEnvironment('ACR_ACCESS_SECRET');
const host = String.fromEnvironment('ACR_HOST');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ACRCloudResponseMusicItem? _music;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_acrcloud example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => _listen(context),
                  child: const Text('Listen'),
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_music case final music?) ...[
                Text('Track: ${music.title}'),
                Text('Album: ${music.album?.name ?? 'unknown'}'),
                Text('Artist: ${music.artists.firstOrNull?.name ?? 'unknown'}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _listen(BuildContext context) async {
    setState(() {
      _music = null;
      _error = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final ACRCloudSession session;

    try {
      if (!ACRCloud.instance.isConfigured) {
        await ACRCloud.instance.configure(
          const ACRCloudConfig(
            accessKey: accessKey,
            accessSecret: accessSecret,
            host: host,
          ),
        );
      }

      session = await ACRCloud.instance.startSession();
    } on ACRCloudException catch (e) {
      setState(() => _error = e.message);
      return;
    }

    if (!context.mounted) {
      // Leaving the session running would block the next startSession().
      await session.cancel();
      return;
    }

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Listening...'),
          content: StreamBuilder<double>(
            stream: session.volume,
            initialData: 0,
            builder: (_, snapshot) =>
                Text('Volume: ${snapshot.data?.toStringAsFixed(2)}'),
          ),
          actions: [
            TextButton(
              onPressed: session.stopAndRecognize,
              child: const Text('Stop now'),
            ),
            TextButton(onPressed: session.cancel, child: const Text('Cancel')),
          ],
        ),
      ),
    );

    final result = await session.result;
    navigator.pop();

    switch (result) {
      case ACRCloudRecognized(:final music):
        setState(() => _music = music.firstOrNull);
        if (music.isEmpty) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Matched a custom file.')),
          );
        }
      case ACRCloudNoMatch():
        messenger.showSnackBar(const SnackBar(content: Text('No match.')));
      case ACRCloudCancelled():
        break;
      case ACRCloudFailure(:final exception):
        setState(() => _error = exception.message);
    }
  }
}
