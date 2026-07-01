import 'workspace_repository.dart';
import 'course_repository.dart';
import 'trainer_repository.dart';
import 'venue_repository.dart';
import 'calendar_repository.dart';
import 'schedule_repository.dart';
import '../app_database.dart';

class RepositoryProvider {
  final AppDatabase db;

  RepositoryProvider(this.db);

  WorkspaceRepository get workspaceRepo => WorkspaceRepository(db);
  CourseRepository get courseRepo => CourseRepository(db);
  TrainerRepository get trainerRepo => TrainerRepository(db);
  VenueRepository get venueRepo => VenueRepository(db);
  CalendarRepository get calendarRepo => CalendarRepository(db);
  ScheduleRepository get scheduleRepo => ScheduleRepository(db);
}
