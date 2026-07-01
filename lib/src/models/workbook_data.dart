import 'assigned_course.dart';
import 'calendar_day.dart';
import 'course.dart';
import 'generated_schedule_row.dart';
import 'lookup_values.dart';
import 'trainer.dart';
import 'venue.dart';

class WorkbookData {
  final List<Course> courses;
  final List<Trainer> trainers;
  final List<Venue> venues;
  final List<CalendarDay> calendar;
  final List<GeneratedScheduleRow> generatedSchedule;
  final LookupValues lookups;
  final List<AssignedCourse> assignedCourses;

  const WorkbookData({
    required this.courses,
    required this.trainers,
    required this.venues,
    required this.calendar,
    required this.generatedSchedule,
    required this.lookups,
    required this.assignedCourses,
  });
}
