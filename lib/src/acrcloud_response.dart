library flutter_acrcloud;

import 'package:json_annotation/json_annotation.dart';

part 'acrcloud_response.g.dart';

/// The root response.
@JsonSerializable()
class ACRCloudResponse {
  final ACRCloudResponseStatus status;
  final ACRCloudResponseMetadata? metadata;

  const ACRCloudResponse(this.status, this.metadata);

  factory ACRCloudResponse.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseFromJson(json);
}

/// Response status, which provides information on any errors that occurred.
@JsonSerializable()
class ACRCloudResponseStatus {
  final String msg;
  final String version;
  final int code;

  const ACRCloudResponseStatus(this.msg, this.version, this.code);

  factory ACRCloudResponseStatus.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseStatusFromJson(json);
}

/// The metadata of the response, which contains all of the matching tracks.
@JsonSerializable()
class ACRCloudResponseMetadata {
  @JsonKey(defaultValue: <ACRCloudResponseMusicItem>[])
  final List<ACRCloudResponseMusicItem> music;

  @JsonKey(
      name: 'custom_files', defaultValue: <ACRCloudResponseCustomFileItem>[])
  final List<ACRCloudResponseCustomFileItem> customFiles;

  const ACRCloudResponseMetadata(this.music, this.customFiles);

  factory ACRCloudResponseMetadata.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseMetadataFromJson(json);
}

/// A single matching track.
@JsonSerializable()
class ACRCloudResponseMusicItem {
  final String? label;

  final ACRCloudResponseAlbum album;

  final List<ACRCloudResponseArtist> artists;

  @JsonKey(name: 'acrid')
  final String acrId;

  @JsonKey(name: 'result_from')
  final int resultFrom;

  final String title;

  @JsonKey(name: 'duration_ms')
  final int durationMs;

  @JsonKey(name: 'release_date')
  final String releaseDate;

  final int score;

  @JsonKey(name: 'play_offset_ms')
  final int playOffsetMs;

  const ACRCloudResponseMusicItem(
      this.label,
      this.album,
      this.artists,
      this.acrId,
      this.resultFrom,
      this.title,
      this.durationMs,
      this.releaseDate,
      this.score,
      this.playOffsetMs);

  factory ACRCloudResponseMusicItem.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseMusicItemFromJson(json);
}

/// The album of an [ACRCloudResponseMusicItem].
@JsonSerializable()
class ACRCloudResponseAlbum {
  final String name;

  const ACRCloudResponseAlbum(this.name);

  factory ACRCloudResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseAlbumFromJson(json);
}

/// The artist of an [ACRCloudResponseMusicItem].
@JsonSerializable()
class ACRCloudResponseArtist {
  final String name;

  const ACRCloudResponseArtist(this.name);

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
  final int durationMs;

  final int score;

  @JsonKey(name: 'play_offset_ms')
  final int playOffsetMs;

  const ACRCloudResponseCustomFileItem(
      this.acrId, this.title, this.durationMs, this.score, this.playOffsetMs);

  factory ACRCloudResponseCustomFileItem.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseCustomFileItemFromJson(json);
}
