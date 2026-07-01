import 'package:drift/drift.dart';
import '../app_database.dart';

class VenueRepository {
  final AppDatabase db;

  VenueRepository(this.db);

  Future<List<Venue>> getVenuesByWorkspace(int workspaceId) async {
    return (db.select(db.venues)
      ..where((t) => t.workspaceId.equals(workspaceId)))
      .get();
  }

  Future<List<DateTime>> getUnavailableDates(int venueId) async {
    final results = await (db.select(db.venueUnavailableDates)
          ..where((t) => t.venueId.equals(venueId)))
        .get();
    return results.map((row) => row.date).toList();
  }

  /// Updates a venue with all fields from the expanded schema.
  Future<void> updateVenue(
    int id, {
    String? name,
    int? capacity,
    String? venueType,
    String? city,
    DateTime? availableFrom,
    DateTime? availableTo,
    String? equipmentNotes,
  }) {
    return (db.update(db.venues)..where((t) => t.id.equals(id))).write(
      VenuesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        capacity: capacity != null ? Value(capacity) : const Value.absent(),
        venueType: venueType != null ? Value(venueType) : const Value.absent(),
        city: city != null ? Value(city) : const Value.absent(),
        availableFrom: availableFrom != null ? Value(availableFrom) : const Value.absent(),
        availableTo: availableTo != null ? Value(availableTo) : const Value.absent(),
        equipmentNotes: equipmentNotes != null ? Value(equipmentNotes) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteVenue(int id) {
    return (db.delete(db.venues)..where((t) => t.id.equals(id))).go();
  }
}
