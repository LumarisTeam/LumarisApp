class WeekStartUtils {
  const WeekStartUtils._();

  static int normalizeWeekStartDay(int? weekStartDay) {
    return switch (weekStartDay) {
      DateTime.monday => DateTime.monday,
      DateTime.sunday => DateTime.sunday,
      _ => DateTime.sunday,
    };
  }

  static DateTime getWeekStart(DateTime date, int weekStartDay) {
    final normalized = normalizeWeekStartDay(weekStartDay);
    final daysSinceWeekStart = (date.weekday - normalized + 7) % 7;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysSinceWeekStart));
  }

  static int getWeekIndexByStartTime(
    DateTime date,
    DateTime startTime, {
    int weekStartDay = DateTime.sunday,
  }) {
    final startWeek = getWeekStart(startTime, weekStartDay);
    final targetWeek = getWeekStart(date, weekStartDay);
    return targetWeek.difference(startWeek).inDays ~/ 7 + 1;
  }

  static List<int> orderedWeekdays(int weekStartDay) {
    final normalized = normalizeWeekStartDay(weekStartDay);
    if (normalized == DateTime.monday) {
      return const [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ];
    }

    return const [
      DateTime.sunday,
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
    ];
  }
}
