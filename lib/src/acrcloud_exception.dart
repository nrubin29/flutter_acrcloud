/// The base class for every error this package throws.
///
/// These represent programmer errors and permission problems. The outcome of a
/// recognition session is *not* an exception — see `ACRCloudResult`.
sealed class ACRCloudException implements Exception {
  final String message;

  const ACRCloudException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a session is started before `ACRCloud.configure` has completed.
final class ACRCloudNotConfiguredException extends ACRCloudException {
  const ACRCloudNotConfiguredException()
    : super(
        'ACRCloud is not configured. Call ACRCloud.instance.configure() and '
        'await it before starting a session.',
      );
}

/// Thrown when a session is started while another one is still active.
final class ACRCloudSessionActiveException extends ACRCloudException {
  const ACRCloudSessionActiveException()
    : super(
        'A recognition session is already active. Cancel it or await its '
        'result before starting another.',
      );
}

/// Thrown when the microphone permission is not available.
final class ACRCloudPermissionDeniedException extends ACRCloudException {
  /// Whether the user denied the permission for good.
  ///
  /// When true, asking again does nothing — send the user to system settings.
  final bool permanently;

  const ACRCloudPermissionDeniedException({required this.permanently})
    : super(
        permanently
            ? 'Microphone permission was permanently denied. The user must '
                  'grant it from system settings.'
            : 'Microphone permission was denied.',
      );
}

/// Thrown when the native ACRCloud SDK reports a failure.
final class ACRCloudPlatformException extends ACRCloudException {
  /// The native error code, for example `INIT_FAILED` or `START_FAILED`.
  final String code;

  const ACRCloudPlatformException({required this.code, required String message})
    : super(message);

  @override
  String toString() => 'ACRCloudPlatformException($code): $message';
}
