import 'dart:convert';

import 'acrcloud_exception.dart';
import 'acrcloud_response.dart';

/// The outcome of a recognition session.
///
/// `ACRCloudSession.result` always completes with one of these and never
/// throws, so callers can handle every case with an exhaustive switch:
///
/// ```dart
/// switch (await session.result) {
///   case ACRCloudRecognized(:final music):  show(music.first);
///   case ACRCloudNoMatch():                 showSnackBar('No match.');
///   case ACRCloudCancelled():               break;
///   case ACRCloudFailure(:final exception): showSnackBar('$exception');
/// }
/// ```
sealed class ACRCloudResult {
  const ACRCloudResult();
}

/// ACRCloud matched at least one track or custom file.
final class ACRCloudRecognized extends ACRCloudResult {
  /// Matching tracks, most confident first. May be empty if only custom files
  /// matched.
  final List<ACRCloudResponseMusicItem> music;

  /// Matching custom files. May be empty if only music matched.
  final List<ACRCloudResponseCustomFileItem> customFiles;

  /// The full parsed response.
  final ACRCloudResponse response;

  /// The verbatim JSON body from ACRCloud, for fields this package does not
  /// model.
  final String rawJson;

  const ACRCloudRecognized({
    required this.music,
    required this.customFiles,
    required this.response,
    required this.rawJson,
  });
}

/// ACRCloud answered successfully, but nothing matched.
final class ACRCloudNoMatch extends ACRCloudResult {
  final ACRCloudResponseStatus status;

  /// The verbatim JSON body from ACRCloud.
  final String rawJson;

  const ACRCloudNoMatch({required this.status, required this.rawJson});
}

/// The session was cancelled by calling `ACRCloudSession.cancel`.
final class ACRCloudCancelled extends ACRCloudResult {
  const ACRCloudCancelled();
}

/// Recognition failed.
///
/// This covers both ACRCloud service errors and native SDK failures. It is
/// delivered here rather than thrown, so awaiting a result is always safe.
final class ACRCloudFailure extends ACRCloudResult {
  final ACRCloudException exception;

  /// The service status, when the failure came from ACRCloud rather than from
  /// the native SDK.
  final ACRCloudResponseStatus? status;

  /// The verbatim JSON body, when there was one.
  final String? rawJson;

  const ACRCloudFailure({required this.exception, this.status, this.rawJson});
}

/// ACRCloud's status code for "the request worked, but nothing matched".
const _noMatchCode = 1001;

/// Turns a raw ACRCloud response body into an [ACRCloudResult].
///
/// Never throws. Unparseable input becomes an [ACRCloudFailure].
ACRCloudResult parseACRCloudResult(String rawJson) {
  final ACRCloudResponse response;

  try {
    response = ACRCloudResponse.fromJson(
      json.decode(rawJson) as Map<String, dynamic>,
    );
  } on Object catch (e) {
    return ACRCloudFailure(
      exception: ACRCloudPlatformException(
        code: 'MALFORMED_RESPONSE',
        message: 'Could not parse the ACRCloud response: $e',
      ),
      rawJson: rawJson,
    );
  }

  final status = response.status;

  if (status.code == _noMatchCode) {
    return ACRCloudNoMatch(status: status, rawJson: rawJson);
  }

  if (status.code != 0) {
    return ACRCloudFailure(
      exception: ACRCloudPlatformException(
        code: 'ACRCLOUD_${status.code}',
        message: status.msg,
      ),
      status: status,
      rawJson: rawJson,
    );
  }

  final metadata = response.metadata;

  if (metadata == null || metadata.isEmpty) {
    return ACRCloudNoMatch(status: status, rawJson: rawJson);
  }

  return ACRCloudRecognized(
    music: metadata.music,
    customFiles: metadata.customFiles,
    response: response,
    rawJson: rawJson,
  );
}
