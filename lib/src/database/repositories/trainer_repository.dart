import 'package:drift/drift.dart';
import '../app_database.dart';

class TrainerRepository {
  final AppDatabase db;

  TrainerRepository(this.db);

  Future<List<Trainer>> getTrainersByWorkspace(int workspaceId) async {
    return (db.select(db.trainers)
      ..where((t) => t.workspaceId.equals(workspaceId)))
      .get();
  }

  Future<List<DateTime>> getUnavailableDates(int trainerId) async {
    final results = await (db.select(db.trainerUnavailableDates)
          ..where((t) => t.trainerId.equals(trainerId)))
        .get();
    return results.map((row) => row.date).toList();
  }

  /// Updates a trainer with all fields from the expanded schema.
  Future<void> updateTrainer(
    int id, {
    String? name,
    String? specialty,
    String? city,
    String? trainerType,
    int? maxDaysPerMonth,
    int? maxConsecutiveDays,
    double? costPerDay,
    String? notes,
  }) {
    return (db.update(db.trainers)..where((t) => t.id.equals(id))).write(
      TrainersCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        specialty: specialty != null ? Value(specialty) : const Value.absent(),
        city: city != null ? Value(city) : const Value.absent(),
        trainerType: trainerType != null ? Value(trainerType) : const Value.absent(),
        maxDaysPerMonth: maxDaysPerMonth != null ? Value(maxDaysPerMonth) : const Value.absent(),
        maxConsecutiveDays: maxConsecutiveDays != null ? Value(maxConsecutiveDays) : const Value.absent(),
        costPerDay: costPerDay != null ? Value(costPerDay) : const Value.absent(),
        notes: notes != null ? Value(notes) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteTrainer(int id) {
    return (db.delete(db.trainers)..where((t) => t.id.equals(id))).go();
  }
}
