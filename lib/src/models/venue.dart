class Venue {
  final String venueId;
  final String venueName;
  final String city;
  final String venueType;
  final int capacity;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final List<DateTime> unavailableDates;
  final String? equipmentNotes;

  const Venue({
    required this.venueId,
    required this.venueName,
    required this.city,
    required this.venueType,
    required this.capacity,
    required this.availableFrom,
    required this.availableTo,
    required this.unavailableDates,
    required this.equipmentNotes,
  });
}
