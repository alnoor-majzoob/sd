import 'dart:math';

import '../models/calendar_day.dart';

class CalendarManager {
  final List<CalendarDay> _days;
  final Map<String, CalendarDay> _dayByKey;
  final Map<String, int> _indexByKey;
  final Random _random;

  CalendarManager(
    List<CalendarDay> days, {
    Random? random,
  })  : _days = List<CalendarDay>.from(days)..sort((a, b) => a.date.compareTo(b.date)),
        _dayByKey = {},
        _indexByKey = {},
        _random = random ?? Random() {
    for (var i = 0; i < _days.length; i++) {
      final key = _dateKey(_days[i].date);
      _dayByKey[key] = _days[i];
      _indexByKey[key] = i;
    }
  }

  CalendarDay? getByDate(DateTime date) => _dayByKey[_dateKey(date)];

  CalendarDay? getRandomDay({
    List<CalendarDay> trainerBusy = const [],
  }) {
    if (_days.isEmpty) {
      return null;
    }

    final trainerBusySet = _toDateKeySet(trainerBusy);
    final startIndex = _random.nextInt(_days.length);

    for (var offset = 0; offset < _days.length; offset++) {
      final index = (startIndex + offset) % _days.length;
      final day = _days[index];
      final key = _dateKey(day.date);

      if (_isUsableDay(day, trainerBusySet, const <String>{}, key)) {
        return day;
      }
    }

    return null;
  }

  CalendarDay? getEndDate({
    required CalendarDay startDate,
    required int courseDuration,
    required List<CalendarDay> trainerBusy,
    required List<CalendarDay> venusBusy,
  }) {
    if (courseDuration <= 0) {
      throw ArgumentError.value(courseDuration, 'courseDuration', 'Must be greater than zero.');
    }

    final startKey = _dateKey(startDate.date);
    final startIndex = _indexByKey[startKey];
    if (startIndex == null) {
      throw StateError('Start date is not part of the managed calendar.');
    }

    final trainerBusySet = _toDateKeySet(trainerBusy);
    final venusBusySet = _toDateKeySet(venusBusy);

    var remainingDays = courseDuration;

    for (var i = startIndex; i < _days.length; i++) {
      final day = _days[i];
      final key = _dateKey(day.date);

      if (!_isUsableDay(day, trainerBusySet, venusBusySet, key)) {
        continue;
      }

      remainingDays--;
      if (remainingDays == 0) {
        return day;
      }
    }

    return null;
  }

  bool _isUsableDay(
    CalendarDay day,
    Set<String> trainerBusySet,
    Set<String> venusBusySet,
    String key,
  ) {
    if (!day.isWorkingDay || day.isHoliday) {
      return false;
    }
    if (trainerBusySet.contains(key)) {
      return false;
    }
    if (venusBusySet.contains(key)) {
      return false;
    }
    return true;
  }

  Set<String> _toDateKeySet(List<CalendarDay> days) {
    final set = <String>{};
    for (final day in days) {
      set.add(_dateKey(day.date));
    }
    return set;
  }

  static String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }
}
