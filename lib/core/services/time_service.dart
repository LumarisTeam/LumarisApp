import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/schedule_time_model.dart';

/// 一张作息表：某个校区在某个季节的节次起止时间。
///
/// 与服务端 `GET /v1/course/ScheduleTime` 返回的 `ScheduleTimeModel` 一一对应。
class ScheduleTable {
  const ScheduleTable({
    required this.campusName,
    this.timeRange = '',
    required this.start,
    required this.end,
  });

  /// 校区名称，例如「草堂校区」「雁塔校区」
  final String campusName;

  /// 适用区间，例如 `10/01~04/30`；不分季节的校区为空串
  final String timeRange;

  /// 各节次的开始时间，下标即节次（0 是早自习，空串表示该节次没课）
  final List<String> start;

  /// 各节次的结束时间，下标含义同 [start]
  final List<String> end;

  factory ScheduleTable.fromModel(ScheduleTimeModel model) => ScheduleTable(
        campusName: model.campusName,
        timeRange: model.time,
        start: model.start,
        end: model.end,
      );

  /// 这张表是否适用于 [date]。
  ///
  /// [timeRange] 为空、或不是 `MM/DD~MM/DD` 形式时视为全年适用。
  bool coversDate(DateTime date) {
    final range = _parseRange(timeRange);
    if (range == null) {
      return true;
    }

    final today = date.month * 100 + date.day;
    final from = range[0] * 100 + range[1];
    final to = range[2] * 100 + range[3];
    // from > to 说明区间跨年，例如 10/01~04/30
    return from <= to
        ? today >= from && today <= to
        : today >= from || today <= to;
  }
}

/// 作息表（各节次的上课时间）查询。
///
/// 数据以服务端 `GET /v1/course/ScheduleTime` 为准，启动和刷新时由
/// `ScheduleTimeService` 装载；这里始终同步读取，UI、课程提醒和小组件
/// 都直接调用。远端数据尚未装载或拉取失败时使用 [builtInTables] 兜底。
class TimeService {
  /// 草堂校区名（与 [ScheduleTable.campusName] 对齐）
  static const String caoTangCampus = '草堂校区';

  /// 雁塔校区名（与 [ScheduleTable.campusName] 对齐）
  static const String yanTaCampus = '雁塔校区';

  /// 内置兜底：草堂校区开始时间（索引 0 是早自习）
  static const List<String> CanTangTimeStart = [
    "8:00",
    "8:30",
    "9:20",
    "10:25",
    "11:15",
    "12:10",
    "13:00",
    "14:00",
    "14:50",
    "15:45",
    "16:35",
    "19:30",
    "20:20"
  ];

  static const List<String> CanTangTimeEnd = [
    "8:20",
    "9:15",
    "10:05",
    "11:10",
    "12:00",
    "12:55",
    "13:45",
    "14:45",
    "15:35",
    "16:30",
    "17:20",
    "20:15",
    "21:05"
  ];

  /// 内置兜底：雁塔冬季的时间表
  static const List<String> YanTaDongStart = [
    "",
    "8:00",
    "9:00",
    "10:10",
    "11:10",
    "",
    "",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "19:30",
    "20:30"
  ];

  static const List<String> YanTaDongEnd = [
    "",
    "8:50",
    "9:50",
    "11:00",
    "12:00",
    "",
    "",
    "14:50",
    "15:50",
    "16:50",
    "17:50",
    "20:20",
    "21:20"
  ];

  /// 内置兜底：雁塔夏季的时间表
  static const List<String> YanTaXiaStart = [
    "",
    "8:00",
    "9:00",
    "10:10",
    "11:10",
    "",
    "",
    "14:30",
    "15:30",
    "16:30",
    "17:30",
    "20:00",
    "21:00"
  ];

  static const List<String> YanTaXiaEnd = [
    "",
    "8:50",
    "9:50",
    "11:00",
    "12:00",
    "",
    "",
    "15:20",
    "16:20",
    "17:30",
    "18:20",
    "20:50",
    "21:50"
  ];

  /// 内置兜底表，内容与服务端 `ScheduleTimeService` 保持一致，仅用于
  /// 首次启动（还没缓存）和拉取失败的情况。
  static const List<ScheduleTable> builtInTables = [
    ScheduleTable(
      campusName: caoTangCampus,
      start: CanTangTimeStart,
      end: CanTangTimeEnd,
    ),
    ScheduleTable(
      campusName: yanTaCampus,
      timeRange: '10/01~04/30',
      start: YanTaDongStart,
      end: YanTaDongEnd,
    ),
    ScheduleTable(
      campusName: yanTaCampus,
      timeRange: '05/01~09/30',
      start: YanTaXiaStart,
      end: YanTaXiaEnd,
    ),
  ];

  static List<ScheduleTable> _tables = builtInTables;
  static bool _isUsingRemoteTables = false;

  /// 当前生效的作息表。
  static List<ScheduleTable> get tables => _tables;

  /// 当前是否用的是服务端下发的表（false 表示还是内置兜底）。
  static bool get isUsingRemoteTables => _isUsingRemoteTables;

  /// 装载服务端下发的作息表；[tables] 为空时退回内置表。
  static void installTables(List<ScheduleTable> tables) {
    if (tables.isEmpty) {
      useBuiltInTables();
      return;
    }

    _tables = List<ScheduleTable>.unmodifiable(tables);
    _isUsingRemoteTables = true;
  }

  /// 退回内置兜底表（登出、测试等场景）。
  static void useBuiltInTables() {
    _tables = builtInTables;
    _isUsingRemoteTables = false;
  }

  /// 由课程字段判定校区名（与 [ScheduleTable.campusName] 对齐）。
  ///
  /// 教务的校区字段可能不准，教室名以「草堂」开头的也算草堂。
  static String resolveCampusName(CourseModel course) {
    final isCaoTang = course.campus == caoTangCampus ||
        (course.room.length >= 2 && course.room.startsWith('草堂'));
    return isCaoTang ? caoTangCampus : yanTaCampus;
  }

  /// 取课程对应的起止时间。
  ///
  /// 同步方法：表在启动/刷新时已装载好。[date] 默认取当前时间，用于选季节。
  static StartAndEnd getStartAndEnd(CourseModel course, {DateTime? date}) {
    return getStartAndEndForCampus(
      campus: resolveCampusName(course),
      startUnit: course.startUnit,
      endUnit: course.endUnit,
      date: date,
    );
  }

  /// 取 [campus] 校区第 [startUnit]~[endUnit] 节课的起止时间。
  ///
  /// 节次超出该校区作息表长度、或表里没有这个校区时，退回草堂的时间；
  /// 都没有则返回空串。
  static StartAndEnd getStartAndEndForCampus({
    required String campus,
    required int startUnit,
    required int endUnit,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final table = _resolveTable(campus, now);
    final fallback =
        campus == caoTangCampus ? null : _resolveTable(caoTangCampus, now);

    return StartAndEnd(
      start: _lookup(table?.start, startUnit) ??
          _lookup(fallback?.start, startUnit) ??
          '',
      end:
          _lookup(table?.end, endUnit) ?? _lookup(fallback?.end, endUnit) ?? '',
    );
  }

  static ScheduleTable? _resolveTable(String campus, DateTime date) {
    final table = _pick(_tables, campus, date);
    if (table != null) {
      return table;
    }

    // 远端数据里没有这个校区（例如服务端改了校区名）时退回内置表。
    return _isUsingRemoteTables ? _pick(builtInTables, campus, date) : null;
  }

  static ScheduleTable? _pick(
    List<ScheduleTable> tables,
    String campus,
    DateTime date,
  ) {
    final candidates =
        tables.where((table) => table.campusName == campus).toList();
    if (candidates.isEmpty) {
      return null;
    }

    for (final table in candidates) {
      if (table.coversDate(date)) {
        return table;
      }
    }

    // 区间都对不上（服务端下发了非法区间）时用第一条，保证不至于没有时间。
    return candidates.first;
  }

  static String? _lookup(List<String>? times, int index) {
    if (times == null || index < 0 || index >= times.length) {
      return null;
    }
    return times[index];
  }
}

/// 把 `MM/DD~MM/DD` 解析成 `[月, 日, 月, 日]`；格式不符时返回 null。
List<int>? _parseRange(String text) {
  final match = RegExp(r'^(\d{1,2})/(\d{1,2})\s*~\s*(\d{1,2})/(\d{1,2})$')
      .firstMatch(text.trim());
  if (match == null) {
    return null;
  }

  return [
    for (var i = 1; i <= 4; i++) int.parse(match.group(i)!),
  ];
}

class StartAndEnd {
  final String start;
  final String end;

  StartAndEnd({
    required this.start,
    required this.end,
  });
}
