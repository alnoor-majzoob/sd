class Course {
  final String courseId;
  final String courseNameAr;
  final String courseNameEn;
  final String specialty;
  final int durationDays;
  final int hoursPerDay;
  final int expectedTrainees;
  final String preferredCitySite;
  final String beneficiary;
  final String deliveryType;
  final String priority;
  final DateTime? earliestStart;
  final DateTime? latestEnd;
  final DateTime? fixedDate;
  final String? notes;

  const Course({
    required this.courseId,
    required this.courseNameAr,
    required this.courseNameEn,
    required this.specialty,
    required this.durationDays,
    required this.hoursPerDay,
    required this.expectedTrainees,
    required this.preferredCitySite,
    required this.beneficiary,
    required this.deliveryType,
    required this.priority,
    required this.earliestStart,
    required this.latestEnd,
    required this.fixedDate,
    required this.notes,
  });
}
