import 'package:json_annotation/json_annotation.dart';

part 'acrcloud_response.g.dart';

/// The root response.
@JsonSerializable()
class ACRCloudResponse {
  final ACRCloudResponseStatus status;
  final ACRCloudResponseMetadata? metadata;

  const ACRCloudResponse({required this.status, this.metadata});

  factory ACRCloudResponse.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseFromJson(json);
}

/// Response status, which provides information on any errors that occurred.
///
/// A [code] of 0 means success. 1001 means the request succeeded but nothing
/// matched. Every other value is an error; see
/// https://docs.acrcloud.com/metadata/error-codes.
@JsonSerializable()
class ACRCloudResponseStatus {
  final String msg;
  final String version;
  final int code;

  const ACRCloudResponseStatus({
    required this.msg,
    required this.version,
    required this.code,
  });

  factory ACRCloudResponseStatus.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseStatusFromJson(json);
}

/// The metadata of the response, which contains all of the matching tracks.
@JsonSerializable()
class ACRCloudResponseMetadata {
  final List<ACRCloudResponseMusicItem> music;

  @JsonKey(name: 'custom_files')
  final List<ACRCloudResponseCustomFileItem> customFiles;

  /// Whether this metadata contains no matches at all.
  bool get isEmpty => music.isEmpty && customFiles.isEmpty;

  const ACRCloudResponseMetadata({
    this.music = const [],
    this.customFiles = const [],
  });

  factory ACRCloudResponseMetadata.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseMetadataFromJson(json);
}

/// A single matching track.
///
/// Only [acrId] and [title] are guaranteed. ACRCloud omits the rest for some
/// matches, so every other field is nullable.
@JsonSerializable()
class ACRCloudResponseMusicItem {
  @JsonKey(name: 'acrid')
  final String acrId;

  final String title;

  final String? label;

  final ACRCloudResponseAlbum? album;

  final List<ACRCloudResponseArtist> artists;

  @JsonKey(name: 'result_from')
  final int? resultFrom;

  @JsonKey(name: 'duration_ms')
  final int? durationMs;

  @JsonKey(name: 'release_date')
  final String? releaseDate;

  final int? score;

  @JsonKey(name: 'play_offset_ms')
  final int? playOffsetMs;

  const ACRCloudResponseMusicItem({
    required this.acrId,
    required this.title,
    this.label,
    this.album,
    this.artists = const [],
    this.resultFrom,
    this.durationMs,
    this.releaseDate,
    this.score,
    this.playOffsetMs,
  });

  factory ACRCloudResponseMusicItem.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseMusicItemFromJson(json);
}

/// The album of an [ACRCloudResponseMusicItem].
@JsonSerializable()
class ACRCloudResponseAlbum {
  final String name;

  const ACRCloudResponseAlbum({required this.name});

  factory ACRCloudResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseAlbumFromJson(json);
}

/// The artist of an [ACRCloudResponseMusicItem].
@JsonSerializable()
class ACRCloudResponseArtist {
  final String name;

  const ACRCloudResponseArtist({required this.name});

  factory ACRCloudResponseArtist.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseArtistFromJson(json);
}

/// A single matching Custom File.
@JsonSerializable()
class ACRCloudResponseCustomFileItem {
  @JsonKey(name: 'acrid')
  final String acrId;

  final String title;

  @JsonKey(name: 'duration_ms')
  final int? durationMs;

  final int? score;

  @JsonKey(name: 'play_offset_ms')
  final int? playOffsetMs;

  const ACRCloudResponseCustomFileItem({
    required this.acrId,
    required this.title,
    this.durationMs,
    this.score,
    this.playOffsetMs,
  });

  factory ACRCloudResponseCustomFileItem.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseCustomFileItemFromJson(json);
}
