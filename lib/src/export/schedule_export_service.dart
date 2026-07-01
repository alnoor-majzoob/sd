import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart' as db;
import '../models/models.dart';

/// Service for exporting workspace data and schedules to Excel files.
class ScheduleExportService {
  final db.AppDatabase _db;
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  ScheduleExportService(this._db);

  /// Exports the full workspace as a multi-sheet Excel workbook.
  /// Returns the saved file path on success, or null if cancelled/failed.
  Future<String?> exportWorkspace(int workspaceId, String workspaceName) async {
    final courses = await _fetchCourses(workspaceId);
    final trainers = await _fetchTrainers(workspaceId);
    final venues = await _fetchVenues(workspaceId);
    final calendar = await _fetchCalendar(workspaceId);
    final scheduleRows =
        await _fetchScheduleExportRows(workspaceId, courses, trainers, venues);
    final assignedCourses = await _fetchAssignedCourses(workspaceId);

    final excel = _createWorkbook();
    _addSummarySheet(excel, workspaceName, courses, trainers, venues, calendar,
        scheduleRows);
    _addScheduleSheet(excel, scheduleRows);
    _addCoursesSheet(excel, courses);
    _addTrainersSheet(excel, trainers);
    _addVenuesSheet(excel, venues);
    _addCalendarSheet(excel, calendar);
    _addAssignedCoursesSheet(excel, assignedCourses, courses, trainers);

    return _saveWorkbook(excel, workspaceName);
  }

  /// Exports only the schedule as a single-sheet Excel workbook ('generated schedules')
  /// running the CPU-heavy Excel creation, cell styling, and ZIP encoding on a separate Isolate.
  Future<String?> exportScheduleOnly(
      int workspaceId, String workspaceName) async {
    final courses = await _fetchCourses(workspaceId);
    final trainers = await _fetchTrainers(workspaceId);
    final venues = await _fetchVenues(workspaceId);
    final scheduleRows =
        await _fetchScheduleExportRows(workspaceId, courses, trainers, venues);

    // Run Excel generation and encoding inside a separate background Isolate to prevent UI thread blocking
    final bytes =
        await Isolate.run(() => _generateScheduleExcelBytes(scheduleRows));
    if (bytes == null) {
      throw const ExportException(
          'Failed to encode generated schedules workbook');
    }

    return _saveBytesAsWorkbook(bytes, '${workspaceName}_Generated_Schedules');
  }

  static List<int>? _generateScheduleExcelBytes(List<ScheduleExportRow> rows) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['generated schedules'];
    final headers = [
      'Course Name',
      'Start Date',
      'End Date',
      'Course Duration',
      'Trainer Name',
      'Venue Name',
      'City Name',
      'Students Number',
      'Binfet',
      'Course Status',
      'Notes',
    ];
    for (int c = 0; c < headers.length; c++) {
      _setStaticCell(sheet, c, 0, headers[c], header: true);
    }
    for (int ri = 0; ri < rows.length; ri++) {
      final row = rows[ri];
      int col = 0;
      void s(Object? v) => _setStaticCell(sheet, col++, ri + 1, v);
      s(row.courseName ?? row.courseId);
      s(row.startDate != null ? dateFormat.format(row.startDate!) : '');
      s(row.endDate != null ? dateFormat.format(row.endDate!) : '');
      s(row.durationDays ?? '');
      s(row.trainerName ?? row.trainerId ?? '');
      s(row.venueName ?? row.venueId ?? '');
      s(row.city ?? '');
      s(row.expectedTrainees ?? '');
      s(row.beneficiary ?? '');
      s(row.status);
      s(row.notes ?? '');
    }
    sheet.setDefaultColumnWidth(0);
    for (int c = 0; c < headers.length; c++) {
      sheet.setColumnWidth(c, 18.0);
    }
    return excel.encode();
  }

  void _addSummarySheet(
      Excel excel,
      String workspaceName,
      List<Course> courses,
      List<Trainer> trainers,
      List<Venue> venues,
      List<CalendarDay> calendar,
      List<ScheduleExportRow> rows) {
    final sheet = excel['Summary'];
    int r = 0;
    void row(List<Object?> values) {
      for (int c = 0; c < values.length; c++)
        _setCell(sheet, c, r, values[c], header: r == 0);
      r++;
    }

    row(['Water Academy - Training Scheduler']);
    row(['Workspace', workspaceName]);
    row(['Exported', _dateTimeFormat.format(DateTime.now())]);
    row([]);
    row(['Entity', 'Count']);
    row(['Courses', courses.length]);
    row(['Trainers', trainers.length]);
    row(['Venues', venues.length]);
    row(['Calendar Days', calendar.length]);
    row(['Scheduled Sessions', rows.length]);
    row([]);
    row(['Published', rows.where((s) => s.status == 'published').length]);
    row(['Not Executed', rows.where((s) => s.status == 'not executed').length]);
    row(['Conflicts', rows.where((s) => s.hasConflict).length]);
    sheet.setDefaultColumnWidth(0);
    sheet.setColumnWidth(0, 1);
  }

  void _addScheduleSheet(Excel excel, List<ScheduleExportRow> rows) {
    final sheet = excel['Schedule'];
    final headers = [
      'ID',
      'Assigned ID',
      'Course ID',
      'Course Name',
      'Trainer ID',
      'Trainer Name',
      'Venue ID',
      'Venue Name',
      'City',
      'Start Date',
      'End Date',
      'Duration',
      'Trainees',
      'Status',
      'Conflict',
      'Delivery Type',
      'Specialty'
    ];
    for (int c = 0; c < headers.length; c++)
      _setCell(sheet, c, 0, headers[c], header: true);
    for (int ri = 0; ri < rows.length; ri++) {
      final row = rows[ri];
      int c = 0;
      void s(Object? v) => _setCell(sheet, c++, ri + 1, v);
      s(row.scheduleId);
      s(row.assignedId);
      s(row.courseId);
      s(row.courseName);
      s(row.trainerId);
      s(row.trainerName);
      s(row.venueId);
      s(row.venueName);
      s(row.city);
      s(row.startDate != null ? _dateFormat.format(row.startDate!) : 'N/A');
      s(row.endDate != null ? _dateFormat.format(row.endDate!) : 'N/A');
      s(row.durationDays);
      s(row.expectedTrainees);
      s(row.status);
      s(row.hasConflict ? 'CONFLICT' : 'OK');
      s(row.deliveryType);
      s(row.specialty);
    }
    sheet.setDefaultColumnWidth(0);
    for (int c = 1; c < headers.length; c++)
      sheet.setColumnWidth(c, c < 9 ? 16.0 : 12.0);
  }

  void _addCoursesSheet(Excel excel, List<Course> courses) {
    final sheet = excel['Courses'];
    final headers = [
      'Course ID',
      'Name (EN)',
      'Name (AR)',
      'Specialty',
      'Duration Days',
      'Hours/Day',
      'Expected Trainees',
      'Preferred City',
      'Beneficiary',
      'Delivery Type',
      'Priority',
      'Earliest Start',
      'Latest End',
      'Fixed Date',
      'Notes'
    ];
    for (int c = 0; c < headers.length; c++)
      _setCell(sheet, c, 0, headers[c], header: true);
    for (int ri = 0; ri < courses.length; ri++) {
      final c = courses[ri];
      int col = 0;
      void set(Object? v) => _setCell(sheet, col++, ri + 1, v);
      set(c.courseId);
      set(c.courseNameEn);
      set(c.courseNameAr);
      set(c.specialty);
      set(c.durationDays);
      set(c.hoursPerDay);
      set(c.expectedTrainees);
      set(c.preferredCitySite);
      set(c.beneficiary);
      set(c.deliveryType);
      set(c.priority);
      set(c.earliestStart != null
          ? _dateFormat.format(c.earliestStart!)
          : null);
      set(c.latestEnd != null ? _dateFormat.format(c.latestEnd!) : null);
      set(c.fixedDate != null ? _dateFormat.format(c.fixedDate!) : null);
      set(c.notes);
    }
  }

  void _addTrainersSheet(Excel excel, List<Trainer> trainers) {
    final sheet = excel['Trainers'];
    final headers = [
      'Trainer ID',
      'Name',
      'City',
      'Type',
      'Specialties',
      'Max Days/Month',
      'Max Consecutive Days',
      'Cost/Day',
      'Unavailable Dates',
      'Notes'
    ];
    for (int c = 0; c < headers.length; c++)
      _setCell(sheet, c, 0, headers[c], header: true);
    for (int ri = 0; ri < trainers.length; ri++) {
      final t = trainers[ri];
      int col = 0;
      void set(Object? v) => _setCell(sheet, col++, ri + 1, v);
      set(t.trainerId);
      set(t.trainerName);
      set(t.city);
      set(t.trainerType);
      set(t.specialties.join(', '));
      set(t.maxDaysPerMonth);
      set(t.maxConsecutiveDays);
      set(t.costPerDay);
      set(t.unavailableDates.isEmpty
          ? 'None'
          : t.unavailableDates.map((d) => _dateFormat.format(d)).join('; '));
      set(t.notes);
    }
  }

  void _addVenuesSheet(Excel excel, List<Venue> venues) {
    final sheet = excel['Venues'];
    final headers = [
      'Venue ID',
      'Name',
      'City',
      'Type',
      'Capacity',
      'Available From',
      'Available To',
      'Unavailable Dates',
      'Equipment Notes'
    ];
    for (int c = 0; c < headers.length; c++)
      _setCell(sheet, c, 0, headers[c], header: true);
    for (int ri = 0; ri < venues.length; ri++) {
      final v = venues[ri];
      int col = 0;
      void set(Object? v) => _setCell(sheet, col++, ri + 1, v);
      set(v.venueId);
      set(v.venueName);
      set(v.city);
      set(v.venueType);
      set(v.capacity);
      set(v.availableFrom != null
          ? _dateFormat.format(v.availableFrom!)
          : null);
      set(v.availableTo != null ? _dateFormat.format(v.availableTo!) : null);
      set(v.unavailableDates.isEmpty
          ? 'None'
          : v.unavailableDates.map((d) => _dateFormat.format(d)).join('; '));
      set(v.equipmentNotes);
    }
  }

  void _addCalendarSheet(Excel excel, List<CalendarDay> calendar) {
    final sheet = excel['Calendar'];
    final headers = [
      'Date',
      'Day Name',
      'Week #',
      'Month',
      'Working Day',
      'Holiday',
      'Notes'
    ];
    for (int c = 0; c < headers.length; c++)
      _setCell(sheet, c, 0, headers[c], header: true);
    for (int ri = 0; ri < calendar.length; ri++) {
      final d = calendar[ri];
      int col = 0;
      void set(Object? v) => _setCell(sheet, col++, ri + 1, v);
      set(_dateFormat.format(d.date));
      set(d.dayName.isNotEmpty ? d.dayName : null);
      set(d.weekNumber > 0 ? d.weekNumber : null);
      set(d.month.isNotEmpty ? d.month : null);
      set(d.isWorkingDay ? 'Yes' : 'No');
      set(d.isHoliday ? 'Yes' : 'No');
      set(d.notes);
    }
  }

  void _addAssignedCoursesSheet(Excel excel, List<AssignedCourse> assigned,
      List<Course> courses, List<Trainer> trainers) {
    final sheet = excel['Assigned Courses'];
    final courseById = {for (final c in courses) c.courseId: c};
    final trainerById = {for (final t in trainers) t.trainerId: t};
    final headers = [
      'Assigned ID',
      'Course ID',
      'Course Name',
      'Trainer ID',
      'Trainer Name',
      'Status'
    ];
    for (int c = 0; c < headers.length; c++)
      _setCell(sheet, c, 0, headers[c], header: true);
    for (int ri = 0; ri < assigned.length; ri++) {
      final a = assigned[ri];
      final course = courseById[a.courseId];
      final trainer = trainerById[a.trainerId];
      _setCell(sheet, 0, ri + 1, a.assignedId);
      _setCell(sheet, 1, ri + 1, a.courseId);
      _setCell(sheet, 2, ri + 1, course?.courseNameEn ?? a.courseId);
      _setCell(sheet, 3, ri + 1, a.trainerId);
      _setCell(sheet, 4, ri + 1, trainer?.trainerName ?? a.trainerId);
      _setCell(sheet, 5, ri + 1, 'not executed');
    }
  }

  Future<List<Course>> _fetchCourses(int workspaceId) async {
    final rows = await (_db.select(_db.courses)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .get();
    return rows
        .map((r) => Course(
              courseId: r.courseId,
              courseNameAr: r.courseNameAr ?? '',
              courseNameEn: r.name,
              specialty: r.specialty ?? '',
              durationDays: r.durationDays,
              hoursPerDay: r.hoursPerDay ?? 8,
              expectedTrainees: r.expectedTrainees,
              preferredCitySite: r.preferredCitySite ?? '',
              beneficiary: r.beneficiary ?? '',
              deliveryType: r.deliveryType,
              priority: r.priority ?? '',
              earliestStart: r.earliestStart,
              latestEnd: r.latestEnd,
              fixedDate: r.fixedDate,
              notes: r.notes,
            ))
        .toList();
  }

  Future<List<Trainer>> _fetchTrainers(int workspaceId) async {
    final rows = await (_db.select(_db.trainers)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .get();
    final result = <Trainer>[];
    for (final t in rows) {
      final unavailable = await (_db.select(_db.trainerUnavailableDates)
            ..where((ud) => ud.trainerId.equals(t.id)))
          .get();
      result.add(Trainer(
        trainerId: t.trainerId,
        trainerName: t.name,
        specialties: t.specialty != null ? [t.specialty!] : [],
        city: t.city ?? '',
        trainerType: t.trainerType ?? '',
        unavailableDates: unavailable.map((u) => u.date).toList(),
        maxDaysPerMonth: t.maxDaysPerMonth ?? 0,
        maxConsecutiveDays: t.maxConsecutiveDays ?? 0,
        costPerDay: t.costPerDay ?? 0.0,
        notes: t.notes,
      ));
    }
    return result;
  }

  Future<List<Venue>> _fetchVenues(int workspaceId) async {
    final rows = await (_db.select(_db.venues)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .get();
    final result = <Venue>[];
    for (final v in rows) {
      final unavailable = await (_db.select(_db.venueUnavailableDates)
            ..where((ud) => ud.venueId.equals(v.id)))
          .get();
      result.add(Venue(
        venueId: v.venueId,
        venueName: v.name,
        city: v.city ?? '',
        venueType: v.venueType,
        capacity: v.capacity,
        availableFrom: v.availableFrom,
        availableTo: v.availableTo,
        unavailableDates: unavailable.map((u) => u.date).toList(),
        equipmentNotes: v.equipmentNotes,
      ));
    }
    return result;
  }

  Future<List<CalendarDay>> _fetchCalendar(int workspaceId) async {
    final rows = await (_db.select(_db.calendarDays)
          ..where((t) => t.workspaceId.equals(workspaceId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return rows
        .map((r) => CalendarDay(
              date: r.date,
              dayName: '',
              isWorkingDay: r.isWorkingDay,
              isHoliday: r.isHoliday,
              weekNumber: 0,
              month: '',
              notes: null,
            ))
        .toList();
  }

  Future<List<AssignedCourse>> _fetchAssignedCourses(int workspaceId) async {
    final rows = await (_db.select(_db.assignedCourses)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .get();
    return rows
        .map((r) => AssignedCourse(
            assignedId: r.assignedId,
            courseId: r.courseId,
            trainerId: r.trainerId))
        .toList();
  }

  Future<List<ScheduleExportRow>> _fetchScheduleExportRows(int workspaceId,
      List<Course> courses, List<Trainer> trainers, List<Venue> venues) async {
    final scheduleRows = await (_db.select(_db.schedules)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .get();
    final assignedRows = await (_db.select(_db.assignedCourses)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .get();
    final courseByAssignedId = <String, Course>{};
    for (final a in assignedRows) {
      final course = courses.where((c) => c.courseId == a.courseId).firstOrNull;
      if (course != null) courseByAssignedId[a.assignedId] = course;
    }
    final trainerByAssignedId = <String, Trainer>{};
    for (final a in assignedRows) {
      final trainer =
          trainers.where((t) => t.trainerId == a.trainerId).firstOrNull;
      if (trainer != null) trainerByAssignedId[a.assignedId] = trainer;
    }
    final venueById = {for (final v in venues) v.venueId: v};
    return scheduleRows.map((s) {
      final course = courseByAssignedId[s.assignedCourseId];
      final trainer = trainerByAssignedId[s.assignedCourseId];
      final venue = s.venueId != null ? venueById[s.venueId] : null;
      return ScheduleExportRow(
        scheduleId: s.id.toString(),
        assignedId: s.assignedCourseId,
        courseId: course?.courseId ?? s.assignedCourseId,
        courseName:
            (course?.courseNameEn != null && course!.courseNameEn.isNotEmpty)
                ? course.courseNameEn
                : course?.courseNameAr,
        trainerId: trainer?.trainerId,
        trainerName: trainer?.trainerName,
        venueId: venue?.venueId,
        venueName: venue?.venueName,
        city: (venue?.city != null && venue!.city.isNotEmpty)
            ? venue.city
            : course?.preferredCitySite,
        startDate: s.startDate,
        endDate: s.endDate,
        durationDays: course?.durationDays,
        expectedTrainees: course?.expectedTrainees,
        status: s.status,
        hasConflict: s.status == 'conflict',
        deliveryType: course?.deliveryType,
        specialty: course?.specialty,
        beneficiary: course?.beneficiary,
        notes: course?.notes,
      );
    }).toList();
  }

  Excel _createWorkbook() {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    return excel;
  }

  Future<String?> _saveWorkbook(Excel excel, String prefix) async {
    final bytes = excel.encode();
    if (bytes == null) throw ExportException('Failed to encode Excel workbook');
    return _saveBytesAsWorkbook(bytes, prefix);
  }

  Future<String?> _saveBytesAsWorkbook(List<int> bytes, String prefix) async {
    final safe =
        prefix.replaceAll(RegExp(r'[^\w\s-]'), '_').replaceAll(' ', '_');
    final name = '${safe}_${_dateFormat.format(DateTime.now())}.xlsx';
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export to Excel',
      fileName: name,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (savePath == null) return null;
    await File(savePath).writeAsBytes(bytes);
    return savePath;
  }

  void _setCell(Sheet sheet, int col, int row, Object? value,
          {bool header = false}) =>
      _setStaticCell(sheet, col, row, value, header: header);

  static void _setStaticCell(Sheet sheet, int col, int row, Object? value,
      {bool header = false}) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    if (value == null) {
      cell.value = null;
      return;
    }
    if (value is String) {
      cell.value = TextCellValue(value);
    } else if (value is int) {
      cell.value = IntCellValue(value);
    } else if (value is double) {
      cell.value = DoubleCellValue(value);
    } else {
      cell.value = TextCellValue(value.toString());
    }
    if (header) {
      cell.cellStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('FF1E3A5F'),
        fontColorHex: ExcelColor.fromHexString('FFFFFFFF'),
        bold: true,
        fontSize: 11,
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }
}

class ScheduleExportRow {
  final String scheduleId;
  final String assignedId;
  final String courseId;
  final String? courseName;
  final String? trainerId;
  final String? trainerName;
  final String? venueId;
  final String? venueName;
  final String? city;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationDays;
  final int? expectedTrainees;
  final String status;
  final bool hasConflict;
  final String? deliveryType;
  final String? specialty;
  final String? beneficiary;
  final String? notes;

  const ScheduleExportRow({
    required this.scheduleId,
    required this.assignedId,
    required this.courseId,
    this.courseName,
    this.trainerId,
    this.trainerName,
    this.venueId,
    this.venueName,
    this.city,
    this.startDate,
    this.endDate,
    this.durationDays,
    this.expectedTrainees,
    required this.status,
    this.hasConflict = false,
    this.deliveryType,
    this.specialty,
    this.beneficiary,
    this.notes,
  });
}

class ExportException implements Exception {
  final String message;
  const ExportException(this.message);
  @override
  String toString() => 'ExportException: $message';
}
