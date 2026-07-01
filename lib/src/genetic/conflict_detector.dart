import '../models/assigned_course.dart';
import '../models/calendar_day.dart';
import '../models/course.dart';
import '../models/venue.dart';
import '../utils/course_utils.dart';
import 'schedule_chromosome.dart';

enum ConflictType {
  trainerOverlap,
  venueOverlap,
  unresolvedGene,
  invalidDateRange,
  capacityExceeded,
  nonWorkingDay,
  holiday,
}

class ConflictDetail {
  final ConflictType type;
  final String assignedCourseId;
  final String message;
  final DateTime? date;
  final String? relatedEntityId;

  const ConflictDetail({
    required this.type,
    required this.assignedCourseId,
    required this.message,
    this.date,
    this.relatedEntityId,
  });
}

class ConflictSummary {
  final int trainerConflicts;
  final int venueConflicts;
  final int unresolvedGenes;
  final int dateRangeConflicts;
  final int capacityConflicts;
  final int nonWorkingDayConflicts;
  final int holidayConflicts;
  final int totalConflicts;
  final double soft;
  final List<ConflictDetail> details;

  const ConflictSummary({
    required this.trainerConflicts,
    required this.venueConflicts,
    required this.unresolvedGenes,
    required this.dateRangeConflicts,
    required this.capacityConflicts,
    required this.nonWorkingDayConflicts,
    required this.holidayConflicts,
    this.soft = 0.0,
    required this.details,
  }) : totalConflicts = trainerConflicts +
            venueConflicts +
            unresolvedGenes +
            dateRangeConflicts +
            capacityConflicts +
            nonWorkingDayConflicts +
            holidayConflicts;
}

class FitnessWeights {
  final int trainerOverlap;
  final int venueOverlap;
  final int unresolvedGene;
  final int invalidDateRange;
  final int capacityExceeded;
  final int nonWorkingDay;
  final int holiday;

  const FitnessWeights({
    this.trainerOverlap = 100,
    this.venueOverlap = 100,
    this.unresolvedGene = 150,
    this.invalidDateRange = 150,
    this.capacityExceeded = 80,
    this.nonWorkingDay = 60,
    this.holiday = 70,
  });
}

class ConflictDetector {
  final Map<String, AssignedCourse> _assignedCourseById;
  final Map<String, Course> _courseById;
  final Map<String, Venue> _venueById;
  final Map<String, CalendarDay> _calendarByDateKey;
  final List<CalendarDay> calendar;
  final FitnessWeights _weights;

  ConflictDetector({
    required List<AssignedCourse> assignedCourses,
    required List<Course> courses,
    required List<Venue> venues,
    required this.calendar,
    FitnessWeights weights = const FitnessWeights(),
  })  : _assignedCourseById = {
          for (final item in assignedCourses) item.assignedId: item
        },
        _courseById = {for (final item in courses) item.courseId: item},
        _venueById = {for (final item in venues) item.venueId: item},
        _calendarByDateKey = {
          for (final item in calendar) _dateKey(item.date): item,
        },
        _weights = weights;

  ConflictSummary detect(ScheduleChromosome chromosome) {
    var trainerConflicts = 0;
    var venueConflicts = 0;
    var unresolvedGenes = 0;
    var dateRangeConflicts = 0;
    var capacityConflicts = 0;
    var nonWorkingDayConflicts = 0;
    var holidayConflicts = 0;
    var soft = 0.0;

    final details = <ConflictDetail>[];
    final trainerDayAssignments = <String, String>{};
    final venueDayAssignments = <String, String>{};

    for (final gene in chromosome.courseGenes) {
      final assigned = _assignedCourseById[gene.assignedCourseId];
      final courseId = assigned?.courseId;
      final trainerId = assigned?.trainerId;
      final course = courseId == null ? null : _courseById[courseId];

      final diff =
          calendar[0].date.difference(gene.startCalendarDay!.date).abs();

      if (diff.inDays < 10) {
        soft += 0.005;
      } else if (diff.inDays < 20) {
        soft += 0.0025;
      } else if (diff.inDays < 30) {
        soft += 0.001;
      } else if (diff.inDays < 40) {
        soft += 0.0005;
      }

      if (assigned == null || trainerId == null || course == null) {
        unresolvedGenes++;
        details.add(ConflictDetail(
          type: ConflictType.unresolvedGene,
          assignedCourseId: gene.assignedCourseId,
          message: 'Assigned course, trainer, or course reference is missing.',
        ));
        continue;
      }

      final isOnline = isOnlineCourse(course);
      final start = gene.startCalendarDay?.date;
      final end = gene.endCalendarDay?.date;
      final venueId = gene.venueId;
      final venue = venueId == null ? null : _venueById[venueId];

      if (start == null || end == null) {
        unresolvedGenes++;
        details.add(ConflictDetail(
          type: ConflictType.unresolvedGene,
          assignedCourseId: gene.assignedCourseId,
          message: 'Start day or end day is missing.',
        ));
        continue;
      }

      if (!isOnline && (venueId == null || venue == null)) {
        unresolvedGenes++;
        details.add(ConflictDetail(
          type: ConflictType.unresolvedGene,
          assignedCourseId: gene.assignedCourseId,
          message: 'Venue reference is missing for a non-online course.',
          relatedEntityId: venueId,
        ));
        continue;
      }

      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);

      if (endDay.isBefore(startDay)) {
        dateRangeConflicts++;
        details.add(ConflictDetail(
          type: ConflictType.invalidDateRange,
          assignedCourseId: gene.assignedCourseId,
          message: 'End day is before start day.',
        ));
        continue;
      }

      if (!isOnline &&
          venue != null &&
          course.expectedTrainees > venue.capacity) {
        capacityConflicts++;
        details.add(ConflictDetail(
          type: ConflictType.capacityExceeded,
          assignedCourseId: gene.assignedCourseId,
          message: 'Expected trainees exceed venue capacity.',
          relatedEntityId: venueId,
        ));
      }

      var current = startDay;
      while (!current.isAfter(endDay)) {
        final dayKey = _dateKey(current);
        final calendarDay = _calendarByDateKey[dayKey];

        if (calendarDay != null) {
          if (!calendarDay.isWorkingDay) {
            nonWorkingDayConflicts++;
            details.add(ConflictDetail(
              type: ConflictType.nonWorkingDay,
              assignedCourseId: gene.assignedCourseId,
              message: 'Course scheduled on a non-working day.',
              date: current,
            ));
          }
          if (calendarDay.isHoliday) {
            holidayConflicts++;
            details.add(ConflictDetail(
              type: ConflictType.holiday,
              assignedCourseId: gene.assignedCourseId,
              message: 'Course scheduled on a holiday.',
              date: current,
            ));
          }
        }

        final trainerKey = '$trainerId|$dayKey';
        final existingTrainerAssignedCourseId =
            trainerDayAssignments[trainerKey];
        if (existingTrainerAssignedCourseId == null) {
          trainerDayAssignments[trainerKey] = gene.assignedCourseId;
        } else if (existingTrainerAssignedCourseId != gene.assignedCourseId) {
          trainerConflicts++;
          details.add(ConflictDetail(
            type: ConflictType.trainerOverlap,
            assignedCourseId: gene.assignedCourseId,
            message: 'Trainer overlap detected with another assigned course.',
            date: current,
            relatedEntityId: existingTrainerAssignedCourseId,
          ));
        }

        if (!isOnline && venueId != null) {
          final venueKey = '$venueId|$dayKey';
          final existingVenueAssignedCourseId = venueDayAssignments[venueKey];
          if (existingVenueAssignedCourseId == null) {
            venueDayAssignments[venueKey] = gene.assignedCourseId;
          } else if (existingVenueAssignedCourseId != gene.assignedCourseId) {
            venueConflicts++;
            details.add(ConflictDetail(
              type: ConflictType.venueOverlap,
              assignedCourseId: gene.assignedCourseId,
              message: 'Venue overlap detected with another assigned course.',
              date: current,
              relatedEntityId: existingVenueAssignedCourseId,
            ));
          }
        }

        current = current.add(const Duration(days: 1));
      }
    }

    return ConflictSummary(
      trainerConflicts: trainerConflicts,
      venueConflicts: venueConflicts,
      unresolvedGenes: unresolvedGenes,
      dateRangeConflicts: dateRangeConflicts,
      capacityConflicts: capacityConflicts,
      nonWorkingDayConflicts: nonWorkingDayConflicts,
      holidayConflicts: holidayConflicts,
      details: details,
      soft: soft,
    );
  }

  int calculatePenalty(ConflictSummary summary) {
    return summary.trainerConflicts * _weights.trainerOverlap +
        summary.venueConflicts * _weights.venueOverlap +
        summary.unresolvedGenes * _weights.unresolvedGene +
        summary.dateRangeConflicts * _weights.invalidDateRange +
        summary.capacityConflicts * _weights.capacityExceeded +
        summary.nonWorkingDayConflicts * _weights.nonWorkingDay +
        summary.holidayConflicts * _weights.holiday;
  }

  double calculateFitness(ScheduleChromosome chromosome) {
    final summary = detect(chromosome);
    final penalty = calculatePenalty(summary);
    return (1.0 / (1.0 + penalty)) + summary.soft;
  }

  // Bug #4 fix: Removed duplicate _isOnlineCourse - using shared isOnlineCourse from course_utils.dart

  static String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }
}
