import 'dart:convert';

import 'package:curriculum/warehouse.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 一次适配仓库导入留下的课表元数据。
///
/// 课程本体仍走 `CourseStore` 的游客课表；这里保存作息、学期配置和来源信息，
/// 供后续的作息表联动、周次计算和诊断使用。
class WarehouseImportedTimetable {
  /// 创建元数据。
  const WarehouseImportedTimetable({
    required this.schoolId,
    required this.schoolName,
    required this.adapterId,
    required this.adapterName,
    required this.importedAt,
    this.timeSlots = const <TimeSlot>[],
    this.config,
    this.comboSchedule,
  });

  /// 学校 id。
  final String schoolId;

  /// 学校名称。
  final String schoolName;

  /// 适配器 id。
  final String adapterId;

  /// 适配器名称。
  final String adapterName;

  /// 导入时间。
  final DateTime importedAt;

  /// 适配器下发的作息。
  final List<TimeSlot> timeSlots;

  /// 适配器下发的学期配置。
  final CourseConfig? config;

  /// 适配器下发的组合作息。
  final ComboSchedule? comboSchedule;

  /// 编码为可持久化的 JSON。
  Map<String, dynamic> toJson() => <String, dynamic>{
    'school_id': schoolId,
    'school_name': schoolName,
    'adapter_id': adapterId,
    'adapter_name': adapterName,
    'imported_at': importedAt.toIso8601String(),
    'time_slots': <Map<String, dynamic>>[
      for (final slot in timeSlots) slot.toJson(),
    ],
    if (config != null) 'config': config!.toJson(),
    if (comboSchedule != null) 'combo_schedule': comboSchedule!.toJson(),
  };

  /// 从持久化 JSON 解码。
  factory WarehouseImportedTimetable.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['time_slots'];
    final rawConfig = json['config'];
    final rawCombo = json['combo_schedule'];
    return WarehouseImportedTimetable(
      schoolId: json['school_id'] is String ? json['school_id'] as String : '',
      schoolName: json['school_name'] is String
          ? json['school_name'] as String
          : '',
      adapterId: json['adapter_id'] is String
          ? json['adapter_id'] as String
          : '',
      adapterName: json['adapter_name'] is String
          ? json['adapter_name'] as String
          : '',
      importedAt:
          DateTime.tryParse(json['imported_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      timeSlots: rawSlots is List
          ? <TimeSlot>[
              for (final item in rawSlots)
                if (item is Map) TimeSlot.fromJson(item.cast<String, dynamic>()),
            ]
          : const <TimeSlot>[],
      config: rawConfig is Map
          ? CourseConfig.fromJson(rawConfig.cast<String, dynamic>())
          : null,
      comboSchedule: rawCombo is Map
          ? ComboSchedule.fromJson(rawCombo.cast<String, dynamic>())
          : null,
    );
  }
}

/// 适配仓库导入元数据的本地存储。
class WarehouseImportStore {
  WarehouseImportStore._();

  /// 读取最近一次导入；没有或已损坏时返回 null。
  static WarehouseImportedTimetable? read() {
    if (!PrefsService.isInitialized) return null;
    final raw = PrefsService.instance.getString(PrefsKeys.WAREHOUSE_IMPORT_DATA);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WarehouseImportedTimetable.fromJson(
        decoded.cast<String, dynamic>(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 保存最近一次导入。
  static Future<void> save(WarehouseImportedTimetable timetable) async {
    await PrefsService.instance.setString(
      PrefsKeys.WAREHOUSE_IMPORT_DATA,
      jsonEncode(timetable.toJson()),
    );
  }

  /// 清除导入元数据。
  static Future<void> clear() async {
    await PrefsService.instance.remove(PrefsKeys.WAREHOUSE_IMPORT_DATA);
  }
}
