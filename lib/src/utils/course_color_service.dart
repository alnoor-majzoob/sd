import 'package:flutter/material.dart';

class CourseColorService {
  static const List<Color> _palette = [
    Color(0xFF2E7D32), // Emerald Green
    Color(0xFF6A1B9A), // Violet Purple
    Color(0xFF00838F), // Deep Cyan
    Color(0xFFE65100), // Burnt Orange
    Color(0xFF1565C0), // Ocean Blue
    Color(0xFFAD1457), // Berry Magenta
    Color(0xFF00695C), // Teal
    Color(0xFFF9A825), // Golden Amber
    Color(0xFF4527A0), // Deep Indigo
    Color(0xFFC62828), // Crimson Red
    Color(0xFF0277BD), // Cobalt
    Color(0xFF558B2F), // Light Green
  ];

  /// Returns a deterministic rich accent color for any course ID or course name.
  static Color getColor(String courseId) {
    if (courseId.isEmpty) return const Color(0xFF1E3A5F);
    final index = courseId.hashCode.abs() % _palette.length;
    return _palette[index];
  }
}
