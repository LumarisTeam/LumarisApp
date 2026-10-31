// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseModelAdapter extends TypeAdapter<CourseModel> {
  @override
  final int typeId = 0;

  @override
  CourseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseModel(
      weekIndexes: (fields[0] as List?)?.cast<int>(),
      teachers: (fields[1] as List?)?.cast<String>(),
      room: fields[2] as String?,
      courseName: fields[3] as String?,
      courseCode: fields[4] as String?,
      weekday: fields[5] as int?,
      startUnit: fields[6] as int?,
      endUnit: fields[7] as int?,
      credits: fields[8] as String?,
      lessonId: fields[9] as String?,
      campus: fields[10] as String?,
      isCustom: fields[11] as bool?,
      isCustomTime: fields[12] as bool?,
      customStartTime: fields[13] as String?,
      customEndTime: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CourseModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.weekIndexes)
      ..writeByte(1)
      ..write(obj.teachers)
      ..writeByte(2)
      ..write(obj.room)
      ..writeByte(3)
      ..write(obj.courseName)
      ..writeByte(4)
      ..write(obj.courseCode)
      ..writeByte(5)
      ..write(obj.weekday)
      ..writeByte(6)
      ..write(obj.startUnit)
      ..writeByte(7)
      ..write(obj.endUnit)
      ..writeByte(8)
      ..write(obj.credits)
      ..writeByte(9)
      ..write(obj.lessonId)
      ..writeByte(10)
      ..write(obj.campus)
      ..writeByte(11)
      ..write(obj.isCustom)
      ..writeByte(12)
      ..write(obj.isCustomTime)
      ..writeByte(13)
      ..write(obj.customStartTime)
      ..writeByte(14)
      ..write(obj.customEndTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
  weekIndexes: parseSchemaIntList(json['weekIndexes']),
  teachers: parseSchemaStringList(json['teachers']),
  room: parseSchemaString(json['room']),
  courseName: parseSchemaString(json['courseName']),
  courseCode: parseSchemaString(json['courseCode']),
  weekday: parseSchemaInt(json['weekday']),
  startUnit: parseSchemaInt(json['startUnit']),
  endUnit: parseSchemaInt(json['endUnit']),
  credits: parseSchemaString(json['credits']),
  lessonId: parseSchemaString(json['lessonId']),
  campus: parseSchemaString(json['campus']),
  isCustom: parseSchemaBool(json['isCustom']),
  isCustomTime: parseSchemaBool(json['isCustomTime']),
  customStartTime: parseSchemaString(json['customStartTime']),
  customEndTime: parseSchemaString(json['customEndTime']),
);

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'weekIndexes': instance.weekIndexes,
      'teachers': instance.teachers,
      'room': instance.room,
      'courseName': instance.courseName,
      'courseCode': instance.courseCode,
      'weekday': instance.weekday,
      'startUnit': instance.startUnit,
      'endUnit': instance.endUnit,
      'credits': instance.credits,
      'lessonId': instance.lessonId,
      'campus': instance.campus,
      'isCustom': instance.isCustom,
      'isCustomTime': instance.isCustomTime,
      'customStartTime': instance.customStartTime,
      'customEndTime': instance.customEndTime,
    };
