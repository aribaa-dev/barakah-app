// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// One place for every colour in the app.
/// Change a colour here -> it changes everywhere.
abstract final class AppColors {
  static const Color background = Color(0xFFF6F6F6);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textBody = Color(0xFF4B5563);

  static const Color accent = Color(0xFFE8872A); // orange
  static const Color accentSoft = Color(0xFFFFF3E8);

  static const Color blue = Color(0xFF4A7FD4);
  static const Color blueSoft = Color(0xFFEAF0FB);

  static const Color green = Color(0xFF2EAA6E);
  static const Color greenSoft = Color(0xFFEAF7F0);

  static const card = Colors.white;
  static const primary = Colors.black87;
  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.black54;
  static const textHint = Colors.black45;
  static const border = Color(0xFFE0E0E0);
}
