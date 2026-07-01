class CalendarDay {
  final DateTime date;
  final String dayName;
  final bool isWorkingDay;
  final bool isHoliday;
  final int weekNumber;
  final String month;
  final String? notes;

  const CalendarDay({
    required this.date,
    required this.dayName,
    required this.isWorkingDay,
    required this.isHoliday,
    required this.weekNumber,
    required this.month,
    required this.notes,
  });
}
