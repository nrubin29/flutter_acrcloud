/// A Flutter plugin for the ACRCloud music recognition API.
///
/// This is a third-party plugin; there is no relation between the developer
/// and ACRCloud.
library;

export 'src/acrcloud.dart' show ACRCloud, ACRCloudConfig, ACRCloudSession;
export 'src/acrcloud_exception.dart';
export 'src/acrcloud_response.dart';
export 'src/acrcloud_result.dart'
    show
        ACRCloudCancelled,
        ACRCloudFailure,
        ACRCloudNoMatch,
        ACRCloudRecognized,
        ACRCloudResult;
export 'src/messages.g.dart' show AcrCloudPermissionStatus;
