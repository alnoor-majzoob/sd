import 'package:drift/drift.dart';
import '../app_database.dart';

class ScheduleRepository {
  final AppDatabase db;

  ScheduleRepository(this.db);

  Future<List<Schedule>> getSchedulesByWorkspace(int workspaceId) {
    return (db.select(db.schedules)..where((t) => t.workspaceId.equals(workspaceId))).get();
  }

  Future<int> saveSchedule({
    required int workspaceId,
    required String assignedCourseId,
    String? venueId,
    required DateTime startDate,
    required DateTime endDate,
    String status = 'not executed',
  }) {
    return db.into(db.schedules).insert(
      SchedulesCompanion.insert(
        workspaceId: workspaceId,
        assignedCourseId: assignedCourseId,
        venueId: Value(venueId),
        startDate: startDate,
        endDate: endDate,
        status: Value(status),
      ),
    );
  }

  Future<void> updateScheduleStatus(int id, String status) {
    return (db.update(db.schedules)..where((t) => t.id.equals(id))).write(
      SchedulesCompanion(status: Value(status)),
    );
  }

  Future<void> clearSchedulesForWorkspace(int workspaceId) {
    return (db.delete(db.schedules)..where((t) => t.workspaceId.equals(workspaceId))).go();
  }
}
