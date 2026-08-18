// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acrcloud_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ACRCloudResponse _$ACRCloudResponseFromJson(Map<String, dynamic> json) =>
    ACRCloudResponse(
      status: ACRCloudResponseStatus.fromJson(
        json['status'] as Map<String, dynamic>,
      ),
      metadata: json['metadata'] == null
          ? null
          : ACRCloudResponseMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

ACRCloudResponseStatus _$ACRCloudResponseStatusFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseStatus(
  msg: json['msg'] as String,
  version: json['version'] as String,
  code: (json['code'] as num).toInt(),
);

ACRCloudResponseMetadata _$ACRCloudResponseMetadataFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseMetadata(
  music:
      (json['music'] as List<dynamic>?)
          ?.map(
            (e) =>
                ACRCloudResponseMusicItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  customFiles:
      (json['custom_files'] as List<dynamic>?)
          ?.map(
            (e) => ACRCloudResponseCustomFileItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
);

ACRCloudResponseMusicItem _$ACRCloudResponseMusicItemFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseMusicItem(
  acrId: json['acrid'] as String,
  title: json['title'] as String,
  label: json['label'] as String?,
  album: json['album'] == null
      ? null
      : ACRCloudResponseAlbum.fromJson(json['album'] as Map<String, dynamic>),
  artists:
      (json['artists'] as List<dynamic>?)
          ?.map(
            (e) => ACRCloudResponseArtist.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  resultFrom: (json['result_from'] as num?)?.toInt(),
  durationMs: (json['duration_ms'] as num?)?.toInt(),
  releaseDate: json['release_date'] as String?,
  score: (json['score'] as num?)?.toInt(),
  playOffsetMs: (json['play_offset_ms'] as num?)?.toInt(),
);

ACRCloudResponseAlbum _$ACRCloudResponseAlbumFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseAlbum(name: json['name'] as String);

ACRCloudResponseArtist _$ACRCloudResponseArtistFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseArtist(name: json['name'] as String);

ACRCloudResponseCustomFileItem _$ACRCloudResponseCustomFileItemFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseCustomFileItem(
  acrId: json['acrid'] as String,
  title: json['title'] as String,
  durationMs: (json['duration_ms'] as num?)?.toInt(),
  score: (json['score'] as num?)?.toInt(),
  playOffsetMs: (json['play_offset_ms'] as num?)?.toInt(),
);
