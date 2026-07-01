import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import 'database/app_database.dart';
import 'database/database_service.dart';
import 'database/repositories/repository_provider.dart';
import 'database/repositories/workspace_repository.dart';
import 'database/repositories/course_repository.dart';
import 'database/repositories/trainer_repository.dart';
import 'database/repositories/venue_repository.dart';
import 'database/repositories/calendar_repository.dart';
import 'database/repositories/schedule_repository.dart';
import 'export/schedule_export_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = '${dir.path}/dart_training_scheduler.db';

  // Database
  final db = AppDatabase.file(dbPath);
  getIt.registerSingleton<AppDatabase>(db);

  // RepositoryProvider — single instance used for all repositories
  final repoProvider = RepositoryProvider(db);
  getIt.registerSingleton<RepositoryProvider>(repoProvider);

  // Services
  getIt.registerSingleton<DatabaseService>(DatabaseService(dbPath: dbPath));

  // Export service
  getIt.registerSingleton<ScheduleExportService>(ScheduleExportService(db));

  // Individual Repositories — all share the same RepositoryProvider instance
  getIt.registerSingleton<WorkspaceRepository>(repoProvider.workspaceRepo);
  getIt.registerSingleton<CourseRepository>(repoProvider.courseRepo);
  getIt.registerSingleton<TrainerRepository>(repoProvider.trainerRepo);
  getIt.registerSingleton<VenueRepository>(repoProvider.venueRepo);
  getIt.registerSingleton<CalendarRepository>(repoProvider.calendarRepo);
  getIt.registerSingleton<ScheduleRepository>(repoProvider.scheduleRepo);
}
