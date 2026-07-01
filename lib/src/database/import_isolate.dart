import 'package:drift/drift.dart';
import 'app_database.dart';
import '../parser/excel_parser.dart';
import 'import_progress.dart';
import 'stream_import_service.dart';

class ImportResult {
  final int workspaceId;
  final bool success;
  final String? error;

  ImportResult(this.workspaceId, this.success, [this.error]);
}

/// Entry point for the import isolate.
///
/// Modes:
/// - [params.workspaceId != null]: Import INTO existing workspace (clears first)
/// - [params.workspaceId == null]: Create NEW workspace, then import
///
/// Sends progress via [ImportProgress] messages, then a final [ImportResult].
void importWorker(ImportWorkerParams params) async {
  final sendPort = params.sendPort;
  int workspaceId = 0;

  void sendProgress(ImportProgress progress) {
    sendPort.send(progress);
  }

  void sendError(String message) {
    sendPort.send(ImportResult(0, false, message));
  }

  sendProgress(const ImportProgress(
    stage: ImportStage.parsing,
    message: 'Initializing database connection...',
  ));

  AppDatabase? db;
  try {
    db = AppDatabase.file(params.dbPath ?? '');

    // ── PHASE 0: Workspace setup ─────────────────────────────

    if (params.workspaceId != null) {
      // ── Import INTO an existing workspace ─────────────────

      final existing = await (db.select(db.scheduleWorkspaces)
            ..where((w) => w.id.equals(params.workspaceId!)))
          .getSingleOrNull();

      if (existing == null) {
        sendError('Workspace ${params.workspaceId} not found.');
        return;
      }

      workspaceId = params.workspaceId!;

      sendProgress(ImportProgress(
        stage: ImportStage.finalizing,
        message: 'Clearing existing data in workspace "${existing.name}"...',
      ));

      await _clearWorkspaceData(db, workspaceId);

      await (db.update(db.scheduleWorkspaces)
            ..where((w) => w.id.equals(workspaceId)))
          .write(ScheduleWorkspacesCompanion(status: const Value('Importing')));
    } else {
      // ── Create a NEW workspace ────────────────────────────

      sendProgress(ImportProgress(
        stage: ImportStage.finalizing,
        message:
            'Creating new workspace "${params.workspaceName ?? 'Imported Workspace'}"...',
      ));

      workspaceId = await db.into(db.scheduleWorkspaces).insert(
            ScheduleWorkspacesCompanion.insert(
              name: params.workspaceName ?? 'Imported Workspace',
              timestamp: DateTime.now(),
              status: 'Importing',
              color: '#4299E1',
            ),
          );
    }

    // ── PHASE 1: Read Excel file via stream ────────────────

    sendProgress(ImportProgress(
      stage: ImportStage.parsing,
      percentage: 0.05,
      message: 'Reading Excel workbook stream...',
    ));

    final parser = ExcelWorkbookParser();
    final excel = await parser.decodeExcelFileStream(params.filePath);

    // ── PHASE 2: Save Courses via Bulk Batch ───────────────

    final courses = parser.parseCoursesSheet(excel);
    sendProgress(ImportProgress.stageStarted(
      stage: ImportStage.savingCourses,
      total: courses.length,
      entityName: 'courses',
      message: 'Importing ${courses.length} courses via bulk batch...',
    ));

    final courseCompanions = courses
        .map((course) => CoursesCompanion(
              workspaceId: Value(workspaceId),
              courseId: Value(course.courseId),
              name: Value(course.courseNameEn),
              durationDays: Value(course.durationDays),
              expectedTrainees: Value(course.expectedTrainees),
              deliveryType: Value(course.deliveryType),
              specialty: Value(course.specialty),
              hoursPerDay: Value(course.hoursPerDay),
              preferredCitySite: Value(course.preferredCitySite),
              beneficiary: Value(course.beneficiary),
              priority: Value(course.priority),
              earliestStart: Value(course.earliestStart),
              latestEnd: Value(course.latestEnd),
              fixedDate: Value(course.fixedDate),
              notes: Value(course.notes),
              courseNameAr: Value(course.courseNameAr),
            ))
        .toList();

    await db.batch((batch) {
      batch.insertAll(db!.courses, courseCompanions);
    });

    sendProgress(ImportProgress.saving(
      stage: ImportStage.savingCourses,
      current: courses.length,
      total: courses.length,
      entityName: 'courses',
    ));

    // ── PHASE 3: Save Trainers via Bulk Batch ──────────────

    final trainers = parser.parseTrainersSheet(excel);
    sendProgress(ImportProgress.stageStarted(
      stage: ImportStage.savingTrainers,
      total: trainers.length,
      entityName: 'trainers',
      message: 'Importing ${trainers.length} trainers via bulk batch...',
    ));

    final trainerCompanions = trainers
        .map((trainer) => TrainersCompanion(
              workspaceId: Value(workspaceId),
              trainerId: Value(trainer.trainerId),
              name: Value(trainer.trainerName),
              specialty: Value(trainer.specialties.isNotEmpty
                  ? trainer.specialties.first
                  : null),
              city: Value(trainer.city),
              trainerType: Value(trainer.trainerType),
              maxDaysPerMonth: Value(trainer.maxDaysPerMonth),
              maxConsecutiveDays: Value(trainer.maxConsecutiveDays),
              costPerDay: Value<double>(trainer.costPerDay.toDouble()),
              notes: Value(trainer.notes),
            ))
        .toList();

    await db.batch((batch) {
      batch.insertAll(db!.trainers, trainerCompanions);
    });

    sendProgress(ImportProgress.saving(
      stage: ImportStage.savingTrainers,
      current: trainers.length,
      total: trainers.length,
      entityName: 'trainers',
    ));

    // ── PHASE 4: Save Venues via Bulk Batch ────────────────

    final venues = parser.parseVenuesSheet(excel);
    sendProgress(ImportProgress.stageStarted(
      stage: ImportStage.savingVenues,
      total: venues.length,
      entityName: 'venues',
      message: 'Importing ${venues.length} venues via bulk batch...',
    ));

    final venueCompanions = venues
        .map((venue) => VenuesCompanion(
              workspaceId: Value(workspaceId),
              venueId: Value(venue.venueId),
              name: Value(venue.venueName),
              capacity: Value(venue.capacity),
              venueType: Value(venue.venueType),
              city: Value(venue.city),
              availableFrom: Value(venue.availableFrom),
              availableTo: Value(venue.availableTo),
              equipmentNotes: Value(venue.equipmentNotes),
            ))
        .toList();

    await db.batch((batch) {
      batch.insertAll(db!.venues, venueCompanions);
    });

    sendProgress(ImportProgress.saving(
      stage: ImportStage.savingVenues,
      current: venues.length,
      total: venues.length,
      entityName: 'venues',
    ));

    // ── PHASE 5: Save Calendar Days via Bulk Batch ─────────

    final calendar = parser.parseCalendarSheet(excel);
    sendProgress(ImportProgress.stageStarted(
      stage: ImportStage.savingCalendar,
      total: calendar.length,
      entityName: 'calendar days',
      message: 'Importing ${calendar.length} calendar days via bulk batch...',
    ));

    final calendarCompanions = calendar
        .map((day) => CalendarDaysCompanion.insert(
              workspaceId: workspaceId,
              date: day.date,
              isWorkingDay: day.isWorkingDay,
              isHoliday: day.isHoliday,
            ))
        .toList();

    await db.batch((batch) {
      batch.insertAll(db!.calendarDays, calendarCompanions);
    });

    sendProgress(ImportProgress.saving(
      stage: ImportStage.savingCalendar,
      current: calendar.length,
      total: calendar.length,
      entityName: 'calendar days',
    ));

    // ── PHASE 6: Save Assigned Courses via Bulk Batch ──────

    final assignedCourses = parser.parseAssignedCoursesSheet(excel);
    sendProgress(ImportProgress.stageStarted(
      stage: ImportStage.savingAssignedCourses,
      total: assignedCourses.length,
      entityName: 'assigned courses',
      message:
          'Importing ${assignedCourses.length} assignments via bulk batch...',
    ));

    final assignedCompanions = assignedCourses
        .map((assigned) => AssignedCoursesCompanion(
              workspaceId: Value(workspaceId),
              assignedId: Value(assigned.assignedId),
              courseId: Value(assigned.courseId),
              trainerId: Value(assigned.trainerId),
              status: const Value('not executed'),
            ))
        .toList();

    await db.batch((batch) {
      batch.insertAll(db!.assignedCourses, assignedCompanions);
    });

    sendProgress(ImportProgress.saving(
      stage: ImportStage.savingAssignedCourses,
      current: assignedCourses.length,
      total: assignedCourses.length,
      entityName: 'assigned courses',
    ));

    // ── PHASE 7: Save Unavailable Dates via Bulk Batch ─────

    final totalUnavailable = trainers.fold<int>(
          0,
          (sum, t) => sum + t.unavailableDates.length,
        ) +
        venues.fold<int>(0, (sum, v) => sum + v.unavailableDates.length);

    sendProgress(ImportProgress.stageStarted(
      stage: ImportStage.savingUnavailableDates,
      total: totalUnavailable,
      entityName: 'unavailable dates',
      message:
          'Importing $totalUnavailable unavailable dates via bulk batch...',
    ));

    final dbTrainersList = await (db.select(db.trainers)
          ..where((t) => t.workspaceId.equals(workspaceId)))
        .get();
    final trainerMap = {for (final t in dbTrainersList) t.trainerId: t.id};

    final trainerUnavailableCompanions = <TrainerUnavailableDatesCompanion>[];
    for (final trainer in trainers) {
      final dbId = trainerMap[trainer.trainerId];
      if (dbId == null) continue;
      for (final date in trainer.unavailableDates) {
        trainerUnavailableCompanions.add(
          TrainerUnavailableDatesCompanion.insert(
            trainerId: dbId,
            date: date,
          ),
        );
      }
    }

    final dbVenuesList = await (db.select(db.venues)
          ..where((v) => v.workspaceId.equals(workspaceId)))
        .get();
    final venueMap = {for (final v in dbVenuesList) v.venueId: v.id};

    final venueUnavailableCompanions = <VenueUnavailableDatesCompanion>[];
    for (final venue in venues) {
      final dbId = venueMap[venue.venueId];
      if (dbId == null) continue;
      for (final date in venue.unavailableDates) {
        venueUnavailableCompanions.add(
          VenueUnavailableDatesCompanion.insert(
            venueId: dbId,
            date: date,
          ),
        );
      }
    }

    await db.batch((batch) {
      if (trainerUnavailableCompanions.isNotEmpty) {
        batch.insertAll(
            db!.trainerUnavailableDates, trainerUnavailableCompanions);
      }
      if (venueUnavailableCompanions.isNotEmpty) {
        batch.insertAll(db!.venueUnavailableDates, venueUnavailableCompanions);
      }
    });

    sendProgress(ImportProgress.saving(
      stage: ImportStage.savingUnavailableDates,
      current: totalUnavailable,
      total: totalUnavailable,
      entityName: 'unavailable dates',
    ));

    // ── PHASE 8: Save Generated Schedule via Bulk Batch ────

    final generatedSchedule = parser.parseGeneratedScheduleSheet(excel);
    if (generatedSchedule.isNotEmpty) {
      sendProgress(ImportProgress.stageStarted(
        stage: ImportStage.finalizing,
        total: generatedSchedule.length,
        entityName: 'schedule rows',
        message:
            'Importing ${generatedSchedule.length} schedule rows via bulk batch...',
      ));

      final dbAssignedList = await (db.select(db.assignedCourses)
            ..where((a) => a.workspaceId.equals(workspaceId)))
          .get();
      final assignedByCourse = <String, AssignedCourse>{};
      for (final a in dbAssignedList) {
        assignedByCourse.putIfAbsent(a.courseId, () => a);
      }

      final venueByName = {for (final v in dbVenuesList) v.name: v};

      final scheduleCompanions = <SchedulesCompanion>[];
      for (final row in generatedSchedule) {
        if (row.courseId == null || row.courseId!.isEmpty) continue;
        if (row.startDate == null || row.endDate == null) continue;

        final assigned = assignedByCourse[row.courseId];
        if (assigned == null) continue;

        String? venueId;
        if (row.venue != null && row.venue!.isNotEmpty) {
          final dbVenue = venueByName[row.venue];
          venueId = dbVenue?.venueId;
        }

        scheduleCompanions.add(
          SchedulesCompanion(
            workspaceId: Value(workspaceId),
            assignedCourseId: Value(assigned.assignedId),
            venueId: Value(venueId),
            startDate: Value(row.startDate!),
            endDate: Value(row.endDate!),
            status: Value(row.status ?? 'not executed'),
          ),
        );
      }

      await db.batch((batch) {
        if (scheduleCompanions.isNotEmpty) {
          batch.insertAll(db!.schedules, scheduleCompanions);
        }
      });

      sendProgress(ImportProgress.saving(
        stage: ImportStage.finalizing,
        current: generatedSchedule.length,
        total: generatedSchedule.length,
        entityName: 'schedule rows',
      ));
    }

    // Final progress message
    sendProgress(ImportProgress(
      stage: ImportStage.finalizing,
      percentage: 0.95,
      message: 'Finalizing workspace...',
    ));

    await (db.update(db.scheduleWorkspaces)
          ..where((w) => w.id.equals(workspaceId)))
        .write(ScheduleWorkspacesCompanion(status: const Value('Ready')));

    sendProgress(ImportProgress.done(workspaceId));
  } catch (e, stackTrace) {
    if (db != null && workspaceId != 0) {
      try {
        await (db.update(db.scheduleWorkspaces)
              ..where((w) => w.id.equals(workspaceId)))
            .write(ScheduleWorkspacesCompanion(
                status: const Value('Import Failed')));
      } catch (_) {}
    }

    sendPort.send(ImportResult(
      0,
      false,
      '${e.runtimeType}: $e\n\nStack trace:\n$stackTrace',
    ));
  }
}

/// Deletes all data for a workspace so it can be cleanly re-imported.
/// BUG D FIX: Now includes Schedules table deletion.
Future<void> _clearWorkspaceData(AppDatabase db, int workspaceId) async {
  // Get all trainer IDs for this workspace
  final trainerIds = await (db.select(db.trainers)
        ..where((t) => t.workspaceId.equals(workspaceId))
        ..addColumns([db.trainers.id]))
      .get();

  // Get all venue IDs for this workspace
  final venueIds = await (db.select(db.venues)
        ..where((v) => v.workspaceId.equals(workspaceId))
        ..addColumns([db.venues.id]))
      .get();

  // Delete unavailable dates using the collected IDs
  if (trainerIds.isNotEmpty) {
    await (db.delete(db.trainerUnavailableDates)
          ..where((t) => t.trainerId.isIn(trainerIds.map((t) => t.id))))
        .go();
  }

  if (venueIds.isNotEmpty) {
    await (db.delete(db.venueUnavailableDates)
          ..where((v) => v.venueId.isIn(venueIds.map((v) => v.id))))
        .go();
  }

  // Delete all entity records for this workspace (in dependency order)
  // BUG D FIX: Added Schedules deletion — previously missing!
  await (db.delete(db.schedules)
        ..where((s) => s.workspaceId.equals(workspaceId)))
      .go();
  await (db.delete(db.assignedCourses)
        ..where((a) => a.workspaceId.equals(workspaceId)))
      .go();
  await (db.delete(db.calendarDays)
        ..where((c) => c.workspaceId.equals(workspaceId)))
      .go();
  await (db.delete(db.courses)..where((c) => c.workspaceId.equals(workspaceId)))
      .go();
  await (db.delete(db.trainers)
        ..where((t) => t.workspaceId.equals(workspaceId)))
      .go();
  await (db.delete(db.venues)..where((v) => v.workspaceId.equals(workspaceId)))
      .go();
}
