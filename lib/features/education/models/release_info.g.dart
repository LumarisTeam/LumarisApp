// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReleaseInfo _$ReleaseInfoFromJson(Map<String, dynamic> json) => ReleaseInfo(
  id: (json['id'] as num).toInt(),
  tagName: json['tag_name'] as String?,
  name: json['name'] as String?,
  body: json['body'] as String?,
  author: json['author'] == null
      ? null
      : AuthorInfo.fromJson(json['author'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  assets: (json['assets'] as List<dynamic>?)
      ?.map((e) => AssetInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReleaseInfoToJson(ReleaseInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tag_name': instance.tagName,
      'name': instance.name,
      'body': instance.body,
      'author': instance.author,
      'created_at': instance.createdAt.toIso8601String(),
      'assets': instance.assets,
    };

AuthorInfo _$AuthorInfoFromJson(Map<String, dynamic> json) =>
    AuthorInfo(id: (json['id'] as num).toInt(), name: json['name'] as String?);

Map<String, dynamic> _$AuthorInfoToJson(AuthorInfo instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

AssetInfo _$AssetInfoFromJson(Map<String, dynamic> json) => AssetInfo(
  browserDownloadUrl: json['browser_download_url'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$AssetInfoToJson(AssetInfo instance) => <String, dynamic>{
  'browser_download_url': instance.browserDownloadUrl,
  'name': instance.name,
};
