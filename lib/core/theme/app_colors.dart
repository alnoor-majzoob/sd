import 'package:flutter/material.dart';

class AppColors {
  // --- Old values kept for fallback (commented) ---
  // background: 0xFFFCF8FA  surface: 0xFFFCF8FA
  // primary: 0xFF000000  primaryContainer: 0xFF131B2E
  // secondary: 0xFF0058BE  secondaryContainer: 0xFF2170E4
  // tertiary: 0xFF000000  tertiaryContainer: 0xFF271901
  // tertiaryFixed: 0xFFFCDEB5  onTertiaryFixedVariant: 0xFF574425

  static const Color background = Color(0xFFF6F7F7);
  static const Color surface = Color(0xFFF6F7F7);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F2F3);
  static const Color surfaceContainer = Color(0xFFE8EBEE);
  static const Color surfaceContainerHigh = Color(0xFFE2E5E8);
  static const Color surfaceContainerHighest = Color(0xFFDCDEE2);
  static const Color surfaceVariant = Color(0xFFDCDEE2);
  static const Color surfaceDim = Color(0xFFD0D3D8);
  static const Color onSurface = Color(0xFF1B1B1D);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color outline = Color(0xFF76777D);
  static const Color outlineVariant = Color(0xFFC6C6CD);
  static const Color primary = Color(0xFF1C67D3);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1350B3);
  static const Color secondary = Color(0xFF1E9DF0);
  static const Color secondaryContainer = Color(0xFF6BC5F8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFF1350B3);
  static const Color tertiaryContainer = Color(0xFF94D4F7);
  static const Color tertiaryFixed = Color(0xFFFCDEB5);
  static const Color onTertiaryFixedVariant = Color(0xFF574425);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color inverseSurface = Color(0xFF303032);
  static const Color inverseOnSurface = Color(0xFFF3F0F2);
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color tertiaryFixed;

  AppThemeExtension({
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.tertiaryFixed,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? surfaceContainerLow,
    Color? surfaceContainerHigh,
    Color? tertiaryFixed,
  }) {
    return AppThemeExtension(
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
    );
  }
}
