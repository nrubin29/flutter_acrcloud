// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acrcloud_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ACRCloudResponse _$ACRCloudResponseFromJson(Map<String, dynamic> json) =>
    ACRCloudResponse(
      ACRCloudResponseStatus.fromJson(json['status'] as Map<String, dynamic>),
      json['metadata'] == null
          ? null
          : ACRCloudResponseMetadata.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

ACRCloudResponseStatus _$ACRCloudResponseStatusFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseStatus(
  json['msg'] as String,
  json['version'] as String,
  (json['code'] as num).toInt(),
);

ACRCloudResponseMetadata _$ACRCloudResponseMetadataFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseMetadata(
  (json['music'] as List<dynamic>?)
          ?.map(
            (e) =>
                ACRCloudResponseMusicItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  (json['custom_files'] as List<dynamic>?)
          ?.map(
            (e) => ACRCloudResponseCustomFileItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      [],
);

ACRCloudResponseMusicItem _$ACRCloudResponseMusicItemFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseMusicItem(
  json['label'] as String?,
  ACRCloudResponseAlbum.fromJson(json['album'] as Map<String, dynamic>),
  (json['artists'] as List<dynamic>)
      .map((e) => ACRCloudResponseArtist.fromJson(e as Map<String, dynamic>))
      .toList(),
  json['acrid'] as String,
  (json['result_from'] as num).toInt(),
  json['title'] as String,
  (json['duration_ms'] as num).toInt(),
  json['release_date'] as String,
  (json['score'] as num).toInt(),
  (json['play_offset_ms'] as num).toInt(),
);

ACRCloudResponseAlbum _$ACRCloudResponseAlbumFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseAlbum(json['name'] as String);

ACRCloudResponseArtist _$ACRCloudResponseArtistFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseArtist(json['name'] as String);

ACRCloudResponseCustomFileItem _$ACRCloudResponseCustomFileItemFromJson(
  Map<String, dynamic> json,
) => ACRCloudResponseCustomFileItem(
  json['acrid'] as String,
  json['title'] as String,
  (json['duration_ms'] as num).toInt(),
  (json['score'] as num).toInt(),
  (json['play_offset_ms'] as num).toInt(),
);
