import '../models/course.dart';

/// Returns true if the course is delivered online or virtually.
///
/// This is a shared utility to avoid duplicating the online/virtual check
/// across multiple genetic algorithm components.
bool isOnlineCourse(Course course) {
  final type = course.deliveryType.trim().toLowerCase();
  return type == 'online' || type == 'virtual';
}
