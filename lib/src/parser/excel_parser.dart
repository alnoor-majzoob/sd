import 'dart:io';

import 'package:excel/excel.dart';

import '../models/models.dart';
import '../utils/parsing_utils.dart';

class ExcelWorkbookParser {
  static const requiredSheets = <String>[
    'Courses',
    'Trainers',
    'Venues',
    'Calendar',
    'Generated Schedule',
    'Lookups',
  ];

  /// Reads the Excel file asynchronously as a stream to avoid memory spikes and UI blocking.
  Future<Excel> decodeExcelFileStream(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Excel file not found', filePath);
    }

    final builder = BytesBuilder();
    await for (final chunk in file.openRead()) {
      builder.add(chunk);
    }
    final excel = Excel.decodeBytes(builder.takeBytes());

    for (final sheet in requiredSheets) {
      if (!excel.tables.containsKey(sheet)) {
        throw StateError('Missing required sheet: $sheet');
      }
    }
    return excel;
  }

  List<Course> parseCoursesSheet(Excel excel) =>
      _parseCourses(excel.tables['Courses']!.rows);

  List<Trainer> parseTrainersSheet(Excel excel) =>
      _parseTrainers(excel.tables['Trainers']!.rows);

  List<Venue> parseVenuesSheet(Excel excel) =>
      _parseVenues(excel.tables['Venues']!.rows);

  List<CalendarDay> parseCalendarSheet(Excel excel) =>
      _parseCalendar(excel.tables['Calendar']!.rows);

  List<AssignedCourse> parseAssignedCoursesSheet(Excel excel) {
    final sheet = _findSheet(excel, 'assigned course');
    return sheet != null ? _parseAssignedCourses(sheet) : <AssignedCourse>[];
  }

  List<GeneratedScheduleRow> parseGeneratedScheduleSheet(Excel excel) =>
      _parseGeneratedSchedule(excel.tables['Generated Schedule']!.rows);

  LookupValues parseLookupsSheet(Excel excel) =>
      _parseLookups(excel.tables['Lookups']!.rows);

  WorkbookData parse(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('Excel file not found', filePath);
    }

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    // Validate required sheets exist (case-sensitive exact match)
    for (final sheet in requiredSheets) {
      if (!excel.tables.containsKey(sheet)) {
        throw StateError('Missing required sheet: $sheet');
      }
    }

    final courses = _parseCourses(excel.tables['Courses']!.rows);
    final trainers = _parseTrainers(excel.tables['Trainers']!.rows);
    final venues = _parseVenues(excel.tables['Venues']!.rows);
    final calendar = _parseCalendar(excel.tables['Calendar']!.rows);
    final generated = _parseGeneratedSchedule(excel.tables['Generated Schedule']!.rows);
    final lookups = _parseLookups(excel.tables['Lookups']!.rows);

    // BUG T FIX: Use case-insensitive sheet lookup for 'assigned course'
    final assignedSheet = _findSheet(excel, 'assigned course');
    final assigned = assignedSheet != null
        ? _parseAssignedCourses(assignedSheet)
        : <AssignedCourse>[];

    return WorkbookData(
      courses: courses,
      trainers: trainers,
      venues: venues,
      calendar: calendar,
      generatedSchedule: generated,
      lookups: lookups,
      assignedCourses: assigned,
    );
  }

  /// Finds a sheet by name (case-insensitive). Returns null if not found.
  List<List<Data?>>? _findSheet(Excel excel, String name) {
    final lc = name.toLowerCase();
    for (final entry in excel.tables.entries) {
      if (entry.key.toLowerCase() == lc) {
        return entry.value.rows;
      }
    }
    return null;
  }

  List<Course> _parseCourses(List<List<Data?>> rows) {
    return rows.skip(1).where((r) => ParsingUtils.asString(r.elementAtOrNull(0)).isNotEmpty).map((r) {
      return Course(
        courseId: ParsingUtils.asString(r.elementAtOrNull(0)),
        courseNameAr: ParsingUtils.asString(r.elementAtOrNull(1)),
        courseNameEn: ParsingUtils.asString(r.elementAtOrNull(2)),
        specialty: ParsingUtils.asString(r.elementAtOrNull(3)),
        durationDays: ParsingUtils.asInt(r.elementAtOrNull(4)),
        hoursPerDay: ParsingUtils.asInt(r.elementAtOrNull(5)),
        expectedTrainees: ParsingUtils.asInt(r.elementAtOrNull(6)),
        preferredCitySite: ParsingUtils.asString(r.elementAtOrNull(7)),
        beneficiary: ParsingUtils.asString(r.elementAtOrNull(8)),
        deliveryType: ParsingUtils.asString(r.elementAtOrNull(9)),
        priority: ParsingUtils.asString(r.elementAtOrNull(10)),
        earliestStart: ParsingUtils.asDate(r.elementAtOrNull(11)),
        latestEnd: ParsingUtils.asDate(r.elementAtOrNull(12)),
        fixedDate: ParsingUtils.asDate(r.elementAtOrNull(13)),
        notes: ParsingUtils.asString(r.elementAtOrNull(14)).isEmpty ? null : ParsingUtils.asString(r.elementAtOrNull(14)),
      );
    }).toList();
  }

  List<Trainer> _parseTrainers(List<List<Data?>> rows) {
    return rows.skip(1).where((r) => ParsingUtils.asString(r.elementAtOrNull(0)).isNotEmpty).map((r) {
      return Trainer(
        trainerId: ParsingUtils.asString(r.elementAtOrNull(0)),
        trainerName: ParsingUtils.asString(r.elementAtOrNull(1)),
        specialties: ParsingUtils.splitCsv(ParsingUtils.asString(r.elementAtOrNull(2))),
        city: ParsingUtils.asString(r.elementAtOrNull(3)),
        trainerType: ParsingUtils.asString(r.elementAtOrNull(4)),
        unavailableDates: ParsingUtils.splitDateList(ParsingUtils.asString(r.elementAtOrNull(5))),
        maxDaysPerMonth: ParsingUtils.asInt(r.elementAtOrNull(6)),
        maxConsecutiveDays: ParsingUtils.asInt(r.elementAtOrNull(7)),
        costPerDay: ParsingUtils.asNum(r.elementAtOrNull(8)),
        notes: ParsingUtils.asString(r.elementAtOrNull(9)).isEmpty ? null : ParsingUtils.asString(r.elementAtOrNull(9)),
      );
    }).toList();
  }

  List<Venue> _parseVenues(List<List<Data?>> rows) {
    return rows.skip(1).where((r) => ParsingUtils.asString(r.elementAtOrNull(0)).isNotEmpty).map((r) {
      return Venue(
        venueId: ParsingUtils.asString(r.elementAtOrNull(0)),
        venueName: ParsingUtils.asString(r.elementAtOrNull(1)),
        city: ParsingUtils.asString(r.elementAtOrNull(2)),
        venueType: ParsingUtils.asString(r.elementAtOrNull(3)),
        capacity: ParsingUtils.asInt(r.elementAtOrNull(4)),
        availableFrom: ParsingUtils.asDate(r.elementAtOrNull(5)),
        availableTo: ParsingUtils.asDate(r.elementAtOrNull(6)),
        unavailableDates: ParsingUtils.splitDateList(ParsingUtils.asString(r.elementAtOrNull(7))),
        equipmentNotes: ParsingUtils.asString(r.elementAtOrNull(8)).isEmpty ? null : ParsingUtils.asString(r.elementAtOrNull(8)),
      );
    }).toList();
  }

  List<CalendarDay> _parseCalendar(List<List<Data?>> rows) {
    return rows.skip(1).where((r) => r.isNotEmpty).map((r) {
      final date = ParsingUtils.asDate(r.elementAtOrNull(0));
      if (date == null) return null;
      return CalendarDay(
        date: date,
        dayName: ParsingUtils.asString(r.elementAtOrNull(1)),
        isWorkingDay: ParsingUtils.asBoolFromYesNo(r.elementAtOrNull(2)),
        isHoliday: ParsingUtils.asBoolFromYesNo(r.elementAtOrNull(3)),
        weekNumber: ParsingUtils.asInt(r.elementAtOrNull(4)),
        month: ParsingUtils.asString(r.elementAtOrNull(5)),
        notes: ParsingUtils.asString(r.elementAtOrNull(6)).isEmpty ? null : ParsingUtils.asString(r.elementAtOrNull(6)),
      );
    }).whereType<CalendarDay>().toList();
  }

  List<GeneratedScheduleRow> _parseGeneratedSchedule(List<List<Data?>> rows) {
    return rows.skip(1).where((r) => r.any((c) => ParsingUtils.asString(c).isNotEmpty)).map((r) {
      var startDate = ParsingUtils.asDate(r.elementAtOrNull(3));
      var endDate = ParsingUtils.asDate(r.elementAtOrNull(4));
      final durationDays = ParsingUtils.asString(r.elementAtOrNull(5)).isEmpty ? null : ParsingUtils.asInt(r.elementAtOrNull(5));

      if (endDate == null && startDate != null && durationDays != null) {
        endDate = startDate.add(Duration(days: durationDays - 1));
      }
      if (startDate == null && endDate != null && durationDays != null) {
        startDate = endDate.subtract(Duration(days: durationDays - 1));
      }

      return GeneratedScheduleRow(
        scheduleId: _nullable(r, 0),
        courseId: _nullable(r, 1),
        courseName: _nullable(r, 2),
        startDate: startDate,
        endDate: endDate,
        durationDays: durationDays,
        trainer1: _nullable(r, 6),
        trainer2: _nullable(r, 7),
        venue: _nullable(r, 8),
        citySite: _nullable(r, 9),
        expectedTrainees: ParsingUtils.asString(r.elementAtOrNull(10)).isEmpty ? null : ParsingUtils.asInt(r.elementAtOrNull(10)),
        status: _nullable(r, 11),
        conflictFlag: _nullable(r, 12),
        score: ParsingUtils.asString(r.elementAtOrNull(13)).isEmpty ? null : ParsingUtils.asNum(r.elementAtOrNull(13)),
        notes: _nullable(r, 14),
      );
    }).toList();
  }

  LookupValues _parseLookups(List<List<Data?>> rows) {
    final priorities = <String>[];
    final deliveryTypes = <String>[];
    final venueTypes = <String>[];
    final statuses = <String>[];
    final yesNo = <String>[];

    for (final r in rows.skip(1)) {
      final c0 = ParsingUtils.asString(r.elementAtOrNull(0));
      final c1 = ParsingUtils.asString(r.elementAtOrNull(1));
      final c2 = ParsingUtils.asString(r.elementAtOrNull(2));
      final c3 = ParsingUtils.asString(r.elementAtOrNull(3));
      final c4 = ParsingUtils.asString(r.elementAtOrNull(4));
      if (c0.isNotEmpty) priorities.add(c0);
      if (c1.isNotEmpty) deliveryTypes.add(c1);
      if (c2.isNotEmpty) venueTypes.add(c2);
      if (c3.isNotEmpty) statuses.add(c3);
      if (c4.isNotEmpty) yesNo.add(c4);
    }

    return LookupValues(
      priorities: priorities,
      deliveryTypes: deliveryTypes,
      venueTypes: venueTypes,
      statuses: statuses,
      yesNo: yesNo,
    );
  }

  List<AssignedCourse> _parseAssignedCourses(List<List<Data?>> rows) {
    return rows.skip(1).where((r) => ParsingUtils.asString(r.elementAtOrNull(0)).isNotEmpty).map((r) {
      return AssignedCourse(
        assignedId: ParsingUtils.asString(r.elementAtOrNull(0)),
        courseId: ParsingUtils.asString(r.elementAtOrNull(1)),
        trainerId: ParsingUtils.asString(r.elementAtOrNull(2)),
      );
    }).toList();
  }

  String? _nullable(List<Data?> row, int index) {
    final value = ParsingUtils.asString(row.elementAtOrNull(index));
    return value.isEmpty ? null : value;
  }
}

extension _SafeListAccess<T> on List<T> {
  T? elementAtOrNull(int index) => index >= 0 && index < length ? this[index] : null;
}
