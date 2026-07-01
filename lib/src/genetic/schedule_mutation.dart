import 'dart:math';

import 'package:genetic_algorithm/genetic_algorithm.dart';

import '../models/assigned_course.dart';
import '../models/calendar_day.dart';
import '../models/course.dart';
import '../models/trainer.dart';
import '../models/venue.dart';
import '../scheduling/calendar_manager.dart';
import '../utils/course_utils.dart';
import 'schedule_chromosome.dart';

class ScheduleMutation extends Mutation<ScheduleChromosome> {
  final List<AssignedCourse> assignedCourses;
  final Map<String, AssignedCourse> assignedCourseById;
  final Map<String, Course> courseById;
  final Map<String, Trainer> trainerById;
  final List<Venue> venues;
  final CalendarManager calendarManager;

  ScheduleMutation({
    required this.assignedCourses,
    required List<Course> courses,
    required List<Trainer> trainers,
    required this.venues,
    required this.calendarManager,
    required super.probability,
  })  : assignedCourseById = {
          for (final item in assignedCourses) item.assignedId: item
        },
        courseById = {for (final item in courses) item.courseId: item},
        trainerById = {for (final item in trainers) item.trainerId: item};

  @override
  ScheduleChromosome mute(ScheduleChromosome chromosome, Random rnd) {
    // Bug #3 fix: Gate mutation by probability - only mutate with the configured probability
    if (rnd.nextDouble() > probability) {
      return chromosome;
    }

    if (chromosome.courseGenes.isEmpty) {
      return chromosome;
    }

    final genes = chromosome.courseGenes
        .map((gene) => gene.clone())
        .toList(growable: true);
    final index = rnd.nextInt(genes.length);
    final oldGene = genes[index];

    final assignment = assignedCourseById[oldGene.assignedCourseId];
    if (assignment == null) {
      return chromosome;
    }

    final course = courseById[assignment.courseId];
    final trainer = trainerById[assignment.trainerId];
    if (course == null || trainer == null) {
      return chromosome;
    }

    final isOnline = isOnlineCourse(course);
    String? venueId;
    List<CalendarDay> venueBusy = const [];

    if (!isOnline) {
      final candidates = _candidateVenues(course);
      if (candidates.isEmpty) {
        return chromosome;
      }
      final venue = candidates[rnd.nextInt(candidates.length)];
      venueId = venue.venueId;
      venueBusy = _venueInputBusyDays(venue);
    }

    final trainerBusy = _trainerInputBusyDays(trainer);
    final startDay = calendarManager.getRandomDay(trainerBusy: trainerBusy);
    if (startDay == null) {
      return chromosome;
    }

    final endDay = calendarManager.getEndDate(
      startDate: startDay,
      courseDuration: course.durationDays,
      trainerBusy: trainerBusy,
      venusBusy: venueBusy,
    );

    final mutated = oldGene.clone(
      venueId: isOnline ? null : venueId,
      startCalendarDay: startDay,
      endCalendarDay: endDay,
    );

    genes[index] = mutated;
    return ScheduleChromosome(courseGenes: List.unmodifiable(genes));
  }

  List<CalendarDay> _trainerInputBusyDays(Trainer trainer) {
    final days = <CalendarDay>[];
    for (final date in trainer.unavailableDates) {
      final day = calendarManager.getByDate(date);
      if (day != null) {
        days.add(day);
      }
    }
    return days;
  }

  List<CalendarDay> _venueInputBusyDays(Venue venue) {
    final days = <CalendarDay>[];
    for (final date in venue.unavailableDates) {
      final day = calendarManager.getByDate(date);
      if (day != null) {
        days.add(day);
      }
    }
    return days;
  }

  // Bug #4 fix: Removed duplicate _isOnlineCourse - using shared isOnlineCourse from course_utils.dart

  List<Venue> _candidateVenues(Course course) {
    return venues.where((venue) {
      if (isOnlineCourse(course)) {
        return false;
      }
      final venueType = venue.venueType.trim().toLowerCase();
      if (venueType == 'online' || venueType == 'virtual') {
        return false;
      }
      return venue.capacity >= course.expectedTrainees;
    }).toList(growable: false);
  }
}
