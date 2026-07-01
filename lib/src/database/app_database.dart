import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────────
// SCHEDULE WORKSPACES
// ─────────────────────────────────────────────────────

class ScheduleWorkspaces extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get status => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().withLength(min: 1, max: 7)(); // Hex color
}

// ─────────────────────────────────────────────────────
// COURSES
// ─────────────────────────────────────────────────────

class Courses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workspaceId => integer().references(ScheduleWorkspaces, #id)();
  TextColumn get courseId => text().withLength(min: 1, max: 50)();
  TextColumn get name => text()(); // courseNameEn
  IntColumn get durationDays => integer()();
  IntColumn get expectedTrainees => integer()();
  TextColumn get deliveryType => text()();

  // Previously dropped — now persisted
  TextColumn get specialty => text().nullable()();
  IntColumn get hoursPerDay => integer().nullable()();
  TextColumn get preferredCitySite => text().nullable()();
  TextColumn get beneficiary => text().nullable()();
  TextColumn get priority => text().nullable()();
  DateTimeColumn get earliestStart => dateTime().nullable()();
  DateTimeColumn get latestEnd => dateTime().nullable()();
  DateTimeColumn get fixedDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get courseNameAr => text().nullable()();
}

// ─────────────────────────────────────────────────────
// TRAINERS
// ─────────────────────────────────────────────────────

class Trainers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workspaceId => integer().references(ScheduleWorkspaces, #id)();
  TextColumn get trainerId => text().withLength(min: 1, max: 50)();
  TextColumn get name => text()();
  TextColumn get specialty => text().nullable()();

  // Previously dropped — now persisted
  TextColumn get city => text().nullable()();
  TextColumn get trainerType => text().nullable()();
  IntColumn get maxDaysPerMonth => integer().nullable()();
  IntColumn get maxConsecutiveDays => integer().nullable()();
  RealColumn get costPerDay => real().nullable()();
  TextColumn get notes => text().nullable()();
}

// ─────────────────────────────────────────────────────
// VENUES
// ─────────────────────────────────────────────────────

class Venues extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workspaceId => integer().references(ScheduleWorkspaces, #id)();
  TextColumn get venueId => text().withLength(min: 1, max: 50)();
  TextColumn get name => text()();
  IntColumn get capacity => integer()();
  TextColumn get venueType => text()();

  // Previously dropped — now persisted
  TextColumn get city => text().nullable()();
  DateTimeColumn get availableFrom => dateTime().nullable()();
  DateTimeColumn get availableTo => dateTime().nullable()();
  TextColumn get equipmentNotes => text().nullable()();
}

// ─────────────────────────────────────────────────────
// CALENDAR DAYS
// ─────────────────────────────────────────────────────

class CalendarDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workspaceId => integer().references(ScheduleWorkspaces, #id)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isWorkingDay => boolean()();
  BoolColumn get isHoliday => boolean()();
}

// ─────────────────────────────────────────────────────
// ASSIGNED COURSES
// ─────────────────────────────────────────────────────

class AssignedCourses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workspaceId => integer().references(ScheduleWorkspaces, #id)();
  TextColumn get assignedId => text().withLength(min: 1, max: 50)();
  TextColumn get courseId => text()();
  TextColumn get trainerId => text()();
  // NEW — status for tracking execution
  TextColumn get status => text().withDefault(const Constant('not executed'))();
}

// ─────────────────────────────────────────────────────
// UNAVAILABLE DATES
// ─────────────────────────────────────────────────────

class TrainerUnavailableDates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get trainerId => integer().references(Trainers, #id)();
  DateTimeColumn get date => dateTime()();
}

class VenueUnavailableDates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get venueId => integer().references(Venues, #id)();
  DateTimeColumn get date => dateTime()();
}

// ─────────────────────────────────────────────────────
// SCHEDULES (Generated Output)
// ─────────────────────────────────────────────────────

class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workspaceId => integer().references(ScheduleWorkspaces, #id)();
  TextColumn get assignedCourseId => text()();
  TextColumn get venueId => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('not executed'))();
}

// ─────────────────────────────────────────────────────
// DATABASE
// ─────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    ScheduleWorkspaces,
    Courses,
    Trainers,
    Venues,
    CalendarDays,
    AssignedCourses,
    TrainerUnavailableDates,
    VenueUnavailableDates,
    Schedules,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(NativeDatabase.memory());
  AppDatabase.file(String path) : super(NativeDatabase(File(path)));

  @override
  int get schemaVersion => 1; // ← Incremented — needs migration
}
