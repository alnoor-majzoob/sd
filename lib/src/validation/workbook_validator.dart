import 'package:collection/collection.dart';

import '../models/models.dart';
import 'validation_issue.dart';

class WorkbookValidator {
  List<ValidationIssue> validate(WorkbookData data) {
    final issues = <ValidationIssue>[];

    issues.addAll(_validateCourses(data));
    issues.addAll(_validateTrainers(data));
    issues.addAll(_validateVenues(data));
    issues.addAll(_validateCalendar(data));
    issues.addAll(_validateAssignments(data));
    issues.addAll(_validateGeneratedSchedule(data));

    return issues;
  }

  List<ValidationIssue> _validateCourses(WorkbookData data) {
    final issues = <ValidationIssue>[];
    final ids = <String>{};

    for (final course in data.courses) {
      if (!ids.add(course.courseId)) {
        issues.add(_error('Courses', course.courseId, 'Course ID', 'Duplicate course ID.'));
      }
      if (course.courseNameAr.trim().isEmpty && course.courseNameEn.trim().isEmpty) {
        issues.add(_error('Courses', course.courseId, 'Course Name', 'At least one course name is required.'));
      }
      if (course.specialty.trim().isEmpty) {
        issues.add(_error('Courses', course.courseId, 'Specialty', 'Specialty is required.'));
      }
      if (course.durationDays <= 0) {
        issues.add(_error('Courses', course.courseId, 'Duration Days', 'Duration must be greater than zero.'));
      }
      if (course.hoursPerDay <= 0 || course.hoursPerDay > 24) {
        issues.add(_error('Courses', course.courseId, 'Hours/Day', 'Hours per day must be between 1 and 24.'));
      }
      if (course.expectedTrainees <= 0) {
        issues.add(_error('Courses', course.courseId, 'Expected Trainees', 'Expected trainees must be greater than zero.'));
      }
      if (!data.lookups.priorities.contains(course.priority)) {
        issues.add(_warning('Courses', course.courseId, 'Priority', 'Priority is not defined in Lookups.'));
      }
      if (!data.lookups.deliveryTypes.contains(course.deliveryType)) {
        issues.add(_warning('Courses', course.courseId, 'Delivery Type', 'Delivery type is not defined in Lookups.'));
      }
      if (course.earliestStart != null && course.latestEnd != null && course.earliestStart!.isAfter(course.latestEnd!)) {
        issues.add(_error('Courses', course.courseId, 'Date Window', 'Earliest start cannot be after latest end.'));
      }
    }
    return issues;
  }

  List<ValidationIssue> _validateTrainers(WorkbookData data) {
    final issues = <ValidationIssue>[];
    final ids = <String>{};

    for (final trainer in data.trainers) {
      if (!ids.add(trainer.trainerId)) {
        issues.add(_error('Trainers', trainer.trainerId, 'Trainer ID', 'Duplicate trainer ID.'));
      }
      if (trainer.trainerName.trim().isEmpty) {
        issues.add(_error('Trainers', trainer.trainerId, 'Trainer Name', 'Trainer name is required.'));
      }
      if (trainer.specialties.isEmpty) {
        issues.add(_error('Trainers', trainer.trainerId, 'Specialties', 'At least one specialty is required.'));
      }
      if (trainer.maxDaysPerMonth < 0) {
        issues.add(_error('Trainers', trainer.trainerId, 'Max Days/Month', 'Must be zero or greater.'));
      }
      if (trainer.maxConsecutiveDays < 0) {
        issues.add(_error('Trainers', trainer.trainerId, 'Max Consecutive Days', 'Must be zero or greater.'));
      }
      if (trainer.costPerDay < 0) {
        issues.add(_error('Trainers', trainer.trainerId, 'Cost/Day', 'Cost cannot be negative.'));
      }
    }
    return issues;
  }

  List<ValidationIssue> _validateVenues(WorkbookData data) {
    final issues = <ValidationIssue>[];
    final ids = <String>{};

    for (final venue in data.venues) {
      if (!ids.add(venue.venueId)) {
        issues.add(_error('Venues', venue.venueId, 'Venue ID', 'Duplicate venue ID.'));
      }
      if (venue.venueName.trim().isEmpty) {
        issues.add(_error('Venues', venue.venueId, 'Venue Name', 'Venue name is required.'));
      }
      if (venue.capacity <= 0) {
        issues.add(_error('Venues', venue.venueId, 'Capacity', 'Capacity must be greater than zero.'));
      }
      if (venue.availableFrom != null && venue.availableTo != null && venue.availableFrom!.isAfter(venue.availableTo!)) {
        issues.add(_error('Venues', venue.venueId, 'Availability Window', 'Available from cannot be after available to.'));
      }
    }
    return issues;
  }

  List<ValidationIssue> _validateCalendar(WorkbookData data) {
    final issues = <ValidationIssue>[];
    final seenDates = <DateTime>{};

    for (final day in data.calendar) {
      final normalized = DateTime(day.date.year, day.date.month, day.date.day);
      if (!seenDates.add(normalized)) {
        issues.add(_error('Calendar', normalized.toIso8601String(), 'Date', 'Duplicate calendar date.'));
      }
      if (day.isHoliday && day.isWorkingDay) {
        issues.add(_warning('Calendar', normalized.toIso8601String(), 'Working/Holiday', 'A day is marked as both working and holiday.'));
      }
    }
    return issues;
  }

  List<ValidationIssue> _validateAssignments(WorkbookData data) {
    final issues = <ValidationIssue>[];
    // BUG F FIX: Track by assignedId (the true PK) — not by courseId.
    // Duplicates on assignedId = real errors. Same course assigned
    // multiple times = valid business scenario, not an error.
    final assignedIds = <String>{};
    final courseIds = data.courses.map((e) => e.courseId).toSet();
    final trainerIds = data.trainers.map((e) => e.trainerId).toSet();

    for (final assignment in data.assignedCourses) {
      // BUG F: was checking courseId (always passes since assignedId is unique).
      // Now correctly checks assignedId — the actual primary key.
      if (!assignedIds.add(assignment.assignedId)) {
        issues.add(_error('assigned course', assignment.assignedId, 'Assigned ID', 'Duplicate assigned course ID.'));
      }
      if (!courseIds.contains(assignment.courseId)) {
        issues.add(_error('assigned course', assignment.assignedId, 'Course ID', 'Referenced course does not exist.'));
      }
      if (!trainerIds.contains(assignment.trainerId)) {
        issues.add(_error('assigned course', assignment.assignedId, 'Trainer ID', 'Referenced trainer does not exist.'));
      }

      // Note: same course assigned to multiple trainers is VALID and not flagged.
      final course = data.courses.firstWhereOrNull((c) => c.courseId == assignment.courseId);
      final trainer = data.trainers.firstWhereOrNull((t) => t.trainerId == assignment.trainerId);
      if (course != null && trainer != null) {
        final compatible = trainer.specialties.any((s) =>
            s.trim().toLowerCase() == course.specialty.trim().toLowerCase() ||
            s.trim().toLowerCase().contains(course.specialty.trim().toLowerCase()) ||
            course.specialty.trim().toLowerCase().contains(s.trim().toLowerCase()));
        if (!compatible) {
          issues.add(_warning('assigned course', assignment.assignedId, 'Trainer ID', 'Assigned trainer specialty may not match course specialty.'));
        }
      }
    }
    return issues;
  }

  List<ValidationIssue> _validateGeneratedSchedule(WorkbookData data) {
    final issues = <ValidationIssue>[];
    final courseIds = data.courses.map((e) => e.courseId).toSet();

    for (final row in data.generatedSchedule.where((e) => e.courseId != null && e.courseId!.isNotEmpty)) {
      if (!courseIds.contains(row.courseId)) {
        issues.add(_warning('Generated Schedule', row.scheduleId ?? 'unknown', 'Course ID', 'Scheduled course does not exist in Courses sheet.'));
      }
      if (row.startDate != null && row.endDate != null && row.startDate!.isAfter(row.endDate!)) {
        issues.add(_error('Generated Schedule', row.scheduleId ?? 'unknown', 'Date Range', 'Start date cannot be after end date.'));
      }
      if (row.status != null && !data.lookups.statuses.contains(row.status)) {
        issues.add(_warning('Generated Schedule', row.scheduleId ?? 'unknown', 'Status', 'Status is not defined in Lookups.'));
      }
    }
    return issues;
  }

  ValidationIssue _error(String sheet, String entityId, String field, String message) => ValidationIssue(
        severity: ValidationSeverity.error,
        sheet: sheet,
        entityId: entityId,
        field: field,
        message: message,
      );

  ValidationIssue _warning(String sheet, String entityId, String field, String message) => ValidationIssue(
        severity: ValidationSeverity.warning,
        sheet: sheet,
        entityId: entityId,
        field: field,
        message: message,
      );
}
