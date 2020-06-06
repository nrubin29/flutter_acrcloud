// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acrcloud_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ACRCloudResponse _$ACRCloudResponseFromJson(Map<String, dynamic> json) {
  return ACRCloudResponse(
    json['status'] == null
        ? null
        : ACRCloudResponseStatus.fromJson(
            json['status'] as Map<String, dynamic>),
    json['metadata'] == null
        ? null
        : ACRCloudResponseMetadata.fromJson(
            json['metadata'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ACRCloudResponseToJson(ACRCloudResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'metadata': instance.metadata,
    };

ACRCloudResponseStatus _$ACRCloudResponseStatusFromJson(
    Map<String, dynamic> json) {
  return ACRCloudResponseStatus(
    json['msg'] as String,
    json['version'] as String,
    json['code'] as int,
  );
}

Map<String, dynamic> _$ACRCloudResponseStatusToJson(
        ACRCloudResponseStatus instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'version': instance.version,
      'code': instance.code,
    };

ACRCloudResponseMetadata _$ACRCloudResponseMetadataFromJson(
    Map<String, dynamic> json) {
  return ACRCloudResponseMetadata(
    (json['music'] as List)
        ?.map((e) => e == null
            ? null
            : ACRCloudResponseMusicItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ACRCloudResponseMetadataToJson(
        ACRCloudResponseMetadata instance) =>
    <String, dynamic>{
      'music': instance.music,
    };

ACRCloudResponseMusicItem _$ACRCloudResponseMusicItemFromJson(
    Map<String, dynamic> json) {
  return ACRCloudResponseMusicItem(
    json['label'] as String,
    json['album'] == null
        ? null
        : ACRCloudResponseAlbum.fromJson(json['album'] as Map<String, dynamic>),
    (json['artists'] as List)
        ?.map((e) => e == null
            ? null
            : ACRCloudResponseArtist.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['acrid'] as String,
    json['result_from'] as int,
    json['title'] as String,
    json['duration_ms'] as int,
    json['release_date'] as String,
    json['score'] as int,
    json['play_offset_ms'] as int,
  );
}

Map<String, dynamic> _$ACRCloudResponseMusicItemToJson(
        ACRCloudResponseMusicItem instance) =>
    <String, dynamic>{
      'label': instance.label,
      'album': instance.album,
      'artists': instance.artists,
      'acrid': instance.acrId,
      'result_from': instance.resultFrom,
      'title': instance.title,
      'duration_ms': instance.durationMs,
      'release_date': instance.releaseDate,
      'score': instance.score,
      'play_offset_ms': instance.playOffsetMs,
    };

ACRCloudResponseAlbum _$ACRCloudResponseAlbumFromJson(
    Map<String, dynamic> json) {
  return ACRCloudResponseAlbum(
    json['name'] as String,
  );
}

Map<String, dynamic> _$ACRCloudResponseAlbumToJson(
        ACRCloudResponseAlbum instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

ACRCloudResponseArtist _$ACRCloudResponseArtistFromJson(
    Map<String, dynamic> json) {
  return ACRCloudResponseArtist(
    json['name'] as String,
  );
}

Map<String, dynamic> _$ACRCloudResponseArtistToJson(
        ACRCloudResponseArtist instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
