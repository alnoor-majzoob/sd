class Trainer {
  final String trainerId;
  final String trainerName;
  final List<String> specialties;
  final String city;
  final String trainerType;
  final List<DateTime> unavailableDates;
  final int maxDaysPerMonth;
  final int maxConsecutiveDays;
  final num costPerDay;
  final String? notes;

  const Trainer({
    required this.trainerId,
    required this.trainerName,
    required this.specialties,
    required this.city,
    required this.trainerType,
    required this.unavailableDates,
    required this.maxDaysPerMonth,
    required this.maxConsecutiveDays,
    required this.costPerDay,
    required this.notes,
  });
}
