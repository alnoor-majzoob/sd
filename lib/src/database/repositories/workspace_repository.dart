import 'package:drift/drift.dart';
import '../app_database.dart';

class WorkspaceRepository {
  final AppDatabase db;

  WorkspaceRepository(this.db);

  Future<List<ScheduleWorkspace>> getAllWorkspaces() {
    return (db.select(db.scheduleWorkspaces)).get();
  }

  Future<ScheduleWorkspace> getWorkspaceById(int id) {
    return (db.select(db.scheduleWorkspaces)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> createWorkspace({
    required String name,
    required String color,
    String status = 'Draft',
  }) {
    return db.into(db.scheduleWorkspaces).insert(
      ScheduleWorkspacesCompanion.insert(
        name: name,
        color: color,
        status: status,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> updateWorkspaceStatus(int id, String status) {
    return (db.update(db.scheduleWorkspaces)..where((t) => t.id.equals(id))).write(
      ScheduleWorkspacesCompanion(status: Value(status)),
    );
  }

  Future<void> deleteWorkspace(int id) {
    return (db.delete(db.scheduleWorkspaces)..where((t) => t.id.equals(id))).go();
  }
}
