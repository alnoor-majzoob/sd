import 'package:drift/drift.dart';
import '../app_database.dart';

class CourseRepository {
  final AppDatabase db;

  CourseRepository(this.db);

  Future<List<Course>> getCoursesByWorkspace(int workspaceId) async {
    return (db.select(db.courses)
      ..where((t) => t.workspaceId.equals(workspaceId)))
      .get();
  }

  Future<Course> getCourseById(int id) async {
    return (db.select(db.courses)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Updates a course with all fields from the expanded schema.
  Future<void> updateCourse(
    int id, {
    String? name,
    String? courseNameAr,
    String? specialty,
    int? durationDays,
    int? hoursPerDay,
    int? expectedTrainees,
    String? preferredCitySite,
    String? beneficiary,
    String? deliveryType,
    String? priority,
    DateTime? earliestStart,
    DateTime? latestEnd,
    DateTime? fixedDate,
    String? notes,
  }) {
    return (db.update(db.courses)..where((t) => t.id.equals(id))).write(
      CoursesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        courseNameAr: courseNameAr != null ? Value(courseNameAr) : const Value.absent(),
        specialty: specialty != null ? Value(specialty) : const Value.absent(),
        durationDays: durationDays != null ? Value(durationDays) : const Value.absent(),
        hoursPerDay: hoursPerDay != null ? Value(hoursPerDay) : const Value.absent(),
        expectedTrainees: expectedTrainees != null ? Value(expectedTrainees) : const Value.absent(),
        preferredCitySite: preferredCitySite != null ? Value(preferredCitySite) : const Value.absent(),
        beneficiary: beneficiary != null ? Value(beneficiary) : const Value.absent(),
        deliveryType: deliveryType != null ? Value(deliveryType) : const Value.absent(),
        priority: priority != null ? Value(priority) : const Value.absent(),
        earliestStart: earliestStart != null ? Value(earliestStart) : const Value.absent(),
        latestEnd: latestEnd != null ? Value(latestEnd) : const Value.absent(),
        fixedDate: fixedDate != null ? Value(fixedDate) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteCourse(int id) {
    return (db.delete(db.courses)..where((t) => t.id.equals(id))).go();
  }
}
