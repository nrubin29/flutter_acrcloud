import 'package:json_annotation/json_annotation.dart';

part 'acrcloud_response.g.dart';

/// The root response.
@JsonSerializable()
class ACRCloudResponse {
  ACRCloudResponseStatus status;
  ACRCloudResponseMetadata? metadata;

  ACRCloudResponse(this.status, this.metadata);

  factory ACRCloudResponse.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseFromJson(json);
}

/// Response status, which provides information on any errors that occurred.
@JsonSerializable()
class ACRCloudResponseStatus {
  String msg;
  String version;
  int code;

  ACRCloudResponseStatus(this.msg, this.version, this.code);

  factory ACRCloudResponseStatus.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseStatusFromJson(json);
}

/// The metadata of the response, which contains all of the matching tracks.
@JsonSerializable()
class ACRCloudResponseMetadata {
  List<ACRCloudResponseMusicItem> music;

  ACRCloudResponseMetadata(this.music);

  factory ACRCloudResponseMetadata.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseMetadataFromJson(json);
}

/// A single matching track.
@JsonSerializable()
class ACRCloudResponseMusicItem {
  String? label;

  ACRCloudResponseAlbum album;

  List<ACRCloudResponseArtist> artists;

  @JsonKey(name: 'acrid')
  String acrId;

  @JsonKey(name: 'result_from')
  int resultFrom;

  String title;

  @JsonKey(name: 'duration_ms')
  int durationMs;

  @JsonKey(name: 'release_date')
  String releaseDate;

  int score;

  @JsonKey(name: 'play_offset_ms')
  int playOffsetMs;

  ACRCloudResponseMusicItem(
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
  String name;

  ACRCloudResponseAlbum(this.name);

  factory ACRCloudResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseAlbumFromJson(json);
}

/// The artist of an [ACRCloudResponseMusicItem].
@JsonSerializable()
class ACRCloudResponseArtist {
  String name;

  ACRCloudResponseArtist(this.name);

  factory ACRCloudResponseArtist.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResponseArtistFromJson(json);
}
