import 'package:json_annotation/json_annotation.dart';

part 'release_info.g.dart';

@JsonSerializable()
class ReleaseInfo {
  final int id;

  @JsonKey(name: 'tag_name')
  final String? tagName;

  final String? name;
  final String? body;
  final AuthorInfo? author;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final List<AssetInfo>? assets;

  ReleaseInfo({
    required this.id,
    this.tagName,
    this.name,
    this.body,
    this.author,
    required this.createdAt,
    this.assets,
  });

  factory ReleaseInfo.fromJson(Map<String, dynamic> json) =>
      _$ReleaseInfoFromJson(_normalizeJsonMap(json));

  Map<String, dynamic> toJson() => _$ReleaseInfoToJson(this);
}

@JsonSerializable()
class AuthorInfo {
  final int id;
  final String? name;

  AuthorInfo({required this.id, this.name});

  factory AuthorInfo.fromJson(Map<String, dynamic> json) =>
      _$AuthorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorInfoToJson(this);
}

@JsonSerializable()
class AssetInfo {
  @JsonKey(name: 'browser_download_url')
  final String? browserDownloadUrl;

  final String? name;

  AssetInfo({this.browserDownloadUrl, this.name});

  factory AssetInfo.fromJson(Map<String, dynamic> json) =>
      _$AssetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetInfoToJson(this);
}

Map<String, dynamic> _normalizeJsonMap(Map<dynamic, dynamic> json) {
  return json.map(
    (key, value) =>
        MapEntry<String, dynamic>(key.toString(), _normalizeJsonValue(value)),
  );
}

dynamic _normalizeJsonValue(dynamic value) {
  if (value is Map) {
    return _normalizeJsonMap(value);
  }
  if (value is List) {
    return value.map(_normalizeJsonValue).toList();
  }
  return value;
}
