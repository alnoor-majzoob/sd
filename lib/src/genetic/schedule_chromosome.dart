import '../models/calendar_day.dart';

class CourseGene {
  final String assignedCourseId;
  final String? venueId;
  final CalendarDay? startCalendarDay;
  final CalendarDay? endCalendarDay;

  const CourseGene({
    required this.assignedCourseId,
    required this.venueId,
    required this.startCalendarDay,
    required this.endCalendarDay,
  });

  CourseGene clone({
    String? venueId,
    CalendarDay? startCalendarDay,
    CalendarDay? endCalendarDay,
  }) {
    return CourseGene(
      assignedCourseId: assignedCourseId,
      venueId: venueId ?? this.venueId,
      startCalendarDay: startCalendarDay ?? this.startCalendarDay,
      endCalendarDay: endCalendarDay ?? this.endCalendarDay,
    );
  }
}

class ScheduleChromosome extends Iterable<CourseGene> {
  final List<CourseGene> courseGenes;

  const ScheduleChromosome({
    required this.courseGenes,
  });

  ScheduleChromosome clone() {
    return ScheduleChromosome(
      courseGenes: courseGenes.map((gene) => gene.clone()).toList(growable: false),
    );
  }

  @override
  Iterator<CourseGene> get iterator => courseGenes.iterator;
}
