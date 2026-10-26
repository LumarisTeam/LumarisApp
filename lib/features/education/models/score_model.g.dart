// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreModelAdapter extends TypeAdapter<ScoreModel> {
  @override
  final int typeId = 1;

  @override
  ScoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreModel(
      name: fields[0] as String,
      lessonCode: fields[1] as String,
      lessonName: fields[2] as String,
      grade: fields[3] as String,
      gpa: fields[4] as String,
      gradeDetail: fields[5] as String,
      credit: fields[6] as String,
      isMinor: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScoreModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.lessonCode)
      ..writeByte(2)
      ..write(obj.lessonName)
      ..writeByte(3)
      ..write(obj.grade)
      ..writeByte(4)
      ..write(obj.gpa)
      ..writeByte(5)
      ..write(obj.gradeDetail)
      ..writeByte(6)
      ..write(obj.credit)
      ..writeByte(7)
      ..write(obj.isMinor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScoreListAdapter extends TypeAdapter<ScoreList> {
  @override
  final int typeId = 2;

  @override
  ScoreList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreList(
      semester: fields[1] as SemesterModel,
      list: (fields[0] as List).cast<ScoreModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScoreList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.list)
      ..writeByte(1)
      ..write(obj.semester);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScoreModel _$ScoreModelFromJson(Map<String, dynamic> json) => ScoreModel(
  name: json['name'] == null ? '' : parseSchemaString(json['name']),
  lessonCode: json['lessonCode'] == null
      ? ''
      : parseSchemaString(json['lessonCode']),
  lessonName: json['lessonName'] == null
      ? ''
      : parseSchemaString(json['lessonName']),
  grade: json['grade'] == null ? '' : parseSchemaString(json['grade']),
  gpa: json['gpa'] == null ? '' : parseSchemaString(json['gpa']),
  gradeDetail: json['gradeDetail'] == null
      ? ''
      : parseSchemaString(json['gradeDetail']),
  credit: json['credit'] == null ? '' : parseSchemaString(json['credit']),
  isMinor: json['isMinor'] == null ? false : parseSchemaBool(json['isMinor']),
);

Map<String, dynamic> _$ScoreModelToJson(ScoreModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'lessonCode': instance.lessonCode,
      'lessonName': instance.lessonName,
      'grade': instance.grade,
      'gpa': instance.gpa,
      'gradeDetail': instance.gradeDetail,
      'credit': instance.credit,
      'isMinor': instance.isMinor,
    };

ScoreList _$ScoreListFromJson(Map<String, dynamic> json) => ScoreList(
  semester: SemesterModel.fromJson(json['semester'] as Map<String, dynamic>),
  list: (json['list'] as List<dynamic>)
      .map((e) => ScoreModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ScoreListToJson(ScoreList instance) => <String, dynamic>{
  'list': instance.list.map((e) => e.toJson()).toList(),
  'semester': instance.semester.toJson(),
};
