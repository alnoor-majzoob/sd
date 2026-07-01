import '../models/models.dart' as domain;
import 'app_database.dart' as db;

/// Maps database entity rows from Drift back to domain models.
/// This is the bidirectional bridge: database rows → domain objects.
class ModelMapper {
  /// Maps a database [db.Course] row to a domain [domain.Course].
  /// Previously dropped fields are now restored from the database.
  static domain.Course mapCourse(db.Course dbCourse) {
    return domain.Course(
      courseId: dbCourse.courseId,
      courseNameAr: dbCourse.courseNameAr ?? '',
      courseNameEn: dbCourse.name,
      specialty: dbCourse.specialty ?? '',
      durationDays: dbCourse.durationDays,
      hoursPerDay: dbCourse.hoursPerDay ?? 8,
      expectedTrainees: dbCourse.expectedTrainees,
      preferredCitySite: dbCourse.preferredCitySite ?? '',
      beneficiary: dbCourse.beneficiary ?? '',
      deliveryType: dbCourse.deliveryType,
      priority: dbCourse.priority ?? '',
      earliestStart: dbCourse.earliestStart,
      latestEnd: dbCourse.latestEnd,
      fixedDate: dbCourse.fixedDate,
      notes: dbCourse.notes,
    );
  }

  /// Maps a database [db.Trainer] row + unavailable dates to a domain [domain.Trainer].
  /// All trainer metadata (city, type, limits, cost) is now preserved.
  static domain.Trainer mapTrainer(db.Trainer dbTrainer, List<DateTime> unavailableDates) {
    return domain.Trainer(
      trainerId: dbTrainer.trainerId,
      trainerName: dbTrainer.name,
      specialties: dbTrainer.specialty != null
          ? [dbTrainer.specialty!]
          : const [], // Fallback to empty list if specialty is null
      city: dbTrainer.city ?? '',
      trainerType: dbTrainer.trainerType ?? '',
      unavailableDates: unavailableDates,
      maxDaysPerMonth: dbTrainer.maxDaysPerMonth ?? 0,
      maxConsecutiveDays: dbTrainer.maxConsecutiveDays ?? 0,
      costPerDay: dbTrainer.costPerDay ?? 0.0,
      notes: dbTrainer.notes,
    );
  }

  /// Maps a database [db.Venue] row + unavailable dates to a domain [domain.Venue].
  /// Venue availability window (availableFrom/availableTo) is now preserved.
  static domain.Venue mapVenue(db.Venue dbVenue, List<DateTime> unavailableDates) {
    return domain.Venue(
      venueId: dbVenue.venueId,
      venueName: dbVenue.name,
      city: dbVenue.city ?? '',
      venueType: dbVenue.venueType,
      capacity: dbVenue.capacity,
      availableFrom: dbVenue.availableFrom,
      availableTo: dbVenue.availableTo,
      unavailableDates: unavailableDates,
      equipmentNotes: dbVenue.equipmentNotes,
    );
  }

  /// Maps a database [db.CalendarDay] row to a domain [domain.CalendarDay].
  /// Note: dayName, weekNumber, month are not stored in the DB and use defaults.
  static domain.CalendarDay mapCalendarDay(db.CalendarDay dbDay) {
    return domain.CalendarDay(
      date: dbDay.date,
      dayName: '', // Not stored in DB
      isWorkingDay: dbDay.isWorkingDay,
      isHoliday: dbDay.isHoliday,
      weekNumber: 0, // Not stored in DB
      month: '',      // Not stored in DB
      notes: null,
    );
  }

  /// Maps a database [db.AssignedCourse] row to a domain [domain.AssignedCourse].
  static domain.AssignedCourse mapAssignedCourse(db.AssignedCourse dbAssigned) {
    return domain.AssignedCourse(
      assignedId: dbAssigned.assignedId,
      courseId: dbAssigned.courseId,
      trainerId: dbAssigned.trainerId,
    );
  }
}