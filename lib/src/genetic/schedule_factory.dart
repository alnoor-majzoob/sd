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

class ScheduleFactory implements PopulationFactory<ScheduleChromosome> {
  final List<AssignedCourse> assignedCourses;
  final Map<String, Course> courseById;
  final Map<String, Trainer> trainerById;
  final List<Venue> venues;
  final CalendarManager calendarManager;
  final double greedyInitializationRatio;

  ScheduleFactory({
    required this.assignedCourses,
    required List<Course> courses,
    required List<Trainer> trainers,
    required this.venues,
    required this.calendarManager,
    required this.greedyInitializationRatio,
  }) : assert(
          greedyInitializationRatio >= 0 && greedyInitializationRatio <= 1,
          'greedyInitializationRatio must be between 0 and 1.',
        ),
       courseById = {for (final item in courses) item.courseId: item},
       trainerById = {for (final item in trainers) item.trainerId: item};

  @override
  ScheduleChromosome generateRandomChromosome(Random rnd) {
    final genes = <CourseGene>[];

    for (final assignment in assignedCourses) {
      final course = courseById[assignment.courseId];
      final trainer = trainerById[assignment.trainerId];
      if (course == null || trainer == null) {
        genes.add(CourseGene(
          assignedCourseId: assignment.assignedId,
          venueId: null,
          startCalendarDay: null,
          endCalendarDay: null,
        ));
        continue;
      }

      final trainerBusy = _trainerInputBusyDays(trainer);
      final isOnline = isOnlineCourse(course);
      final candidateVenues = isOnline ? const <Venue>[] : _candidateVenues(course, rnd);

      final startDay = calendarManager.getRandomDay(trainerBusy: trainerBusy);
      if (startDay == null) {
        genes.add(CourseGene(
          assignedCourseId: assignment.assignedId,
          venueId: null,
          startCalendarDay: null,
          endCalendarDay: null,
        ));
        continue;
      }

      String? selectedVenueId;
      CalendarDay? endDay;

      if (isOnline) {
        endDay = calendarManager.getEndDate(
          startDate: startDay,
          courseDuration: course.durationDays,
          trainerBusy: trainerBusy,
          venusBusy: const [],
        );
      } else {
        for (final venue in candidateVenues) {
          final venueBusy = _venueInputBusyDays(venue);
          final candidateEndDay = calendarManager.getEndDate(
            startDate: startDay,
            courseDuration: course.durationDays,
            trainerBusy: trainerBusy,
            venusBusy: venueBusy,
          );
          if (candidateEndDay != null) {
            selectedVenueId = venue.venueId;
            endDay = candidateEndDay;
            break;
          }
        }
      }

      genes.add(CourseGene(
        assignedCourseId: assignment.assignedId,
        venueId: isOnline ? null : selectedVenueId,
        startCalendarDay: startDay,
        endCalendarDay: endDay,
      ));
    }

    return ScheduleChromosome(courseGenes: List.unmodifiable(genes));
  }

  ScheduleChromosome generateGreedyChromosome(Random rnd) {
    final genes = <CourseGene>[];

    final sortedAssignments = List<AssignedCourse>.from(assignedCourses)
      ..sort((a, b) {
        final courseA = courseById[a.courseId];
        final courseB = courseById[b.courseId];
        final durationA = courseA?.durationDays ?? 0;
        final durationB = courseB?.durationDays ?? 0;
        return durationB.compareTo(durationA);
      });

    for (final assignment in sortedAssignments) {
      final course = courseById[assignment.courseId];
      final trainer = trainerById[assignment.trainerId];
      if (course == null || trainer == null) {
        genes.add(CourseGene(
          assignedCourseId: assignment.assignedId,
          venueId: null,
          startCalendarDay: null,
          endCalendarDay: null,
        ));
        continue;
      }

      final trainerBusy = _trainerInputBusyDays(trainer);
      final startDay = calendarManager.getRandomDay(trainerBusy: trainerBusy);
      if (startDay == null) {
        genes.add(CourseGene(
          assignedCourseId: assignment.assignedId,
          venueId: null,
          startCalendarDay: null,
          endCalendarDay: null,
        ));
        continue;
      }

      final isOnline = isOnlineCourse(course);
      String? selectedVenueId;
      CalendarDay? endDay;

      if (isOnline) {
        endDay = calendarManager.getEndDate(
          startDate: startDay,
          courseDuration: course.durationDays,
          trainerBusy: trainerBusy,
          venusBusy: const [],
        );
      } else {
        final candidateVenues = _candidateVenues(course, rnd);
        for (final venue in candidateVenues) {
          final venueBusy = _venueInputBusyDays(venue);
          final candidateEndDay = calendarManager.getEndDate(
            startDate: startDay,
            courseDuration: course.durationDays,
            trainerBusy: trainerBusy,
            venusBusy: venueBusy,
          );
          if (candidateEndDay != null) {
            selectedVenueId = venue.venueId;
            endDay = candidateEndDay;
            break;
          }
        }
      }

      genes.add(CourseGene(
        assignedCourseId: assignment.assignedId,
        venueId: isOnline ? null : selectedVenueId,
        startCalendarDay: startDay,
        endCalendarDay: endDay,
      ));
    }

    return ScheduleChromosome(courseGenes: List.unmodifiable(genes));
  }

  @override
  Population<ScheduleChromosome> generateInitialPopulation(int size, List<ScheduleChromosome> seeds, Random rnd) {
    final chromosomes = <Chromosome<ScheduleChromosome>>[
      ...seeds.map((e) => Chromosome.data(e)),
    ];

    for (int i = seeds.length; i < size; i++) {
      final useGreedy = rnd.nextDouble() < greedyInitializationRatio;
      chromosomes.add(Chromosome.data(useGreedy ? generateGreedyChromosome(rnd) : generateRandomChromosome(rnd)));
    }

    return Population(chromosomes);
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

  List<Venue> _candidateVenues(Course course, Random rnd) {
    final candidates = venues.where((venue) {
      if (isOnlineCourse(course)) {
        return false;
      }
      final venueType = venue.venueType.trim().toLowerCase();
      if (venueType == 'online' || venueType == 'virtual') {
        return false;
      }
      return venue.capacity >= course.expectedTrainees;
    }).toList();

    candidates.shuffle(rnd);
    candidates.sort((a, b) => a.capacity.compareTo(b.capacity));
    return candidates;
  }
}
