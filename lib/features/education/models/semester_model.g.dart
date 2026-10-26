// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SemesterModelAdapter extends TypeAdapter<SemesterModel> {
  @override
  final int typeId = 3;

  @override
  SemesterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SemesterModel(
      semester: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SemesterModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.semester)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterModel _$SemesterModelFromJson(Map<String, dynamic> json) =>
    SemesterModel(
      semester: parseSchemaString(json['value']),
      name: parseSchemaString(json['text']),
    );

Map<String, dynamic> _$SemesterModelToJson(SemesterModel instance) =>
    <String, dynamic>{'value': instance.semester, 'text': instance.name};
