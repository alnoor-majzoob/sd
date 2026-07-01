import '../app_database.dart';

class CalendarRepository {
  final AppDatabase db;

  CalendarRepository(this.db);

  Future<List<CalendarDay>> getCalendarByWorkspace(int workspaceId) {
    return (db.select(db.calendarDays)..where((t) => t.workspaceId.equals(workspaceId))).get();
  }
}
