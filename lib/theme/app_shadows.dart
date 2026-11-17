import 'package:flutter/material.dart';

/// BoxShadow presets matching the soft tactile glass aesthetic.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> glassCard = [
    BoxShadow(
      color: Color(0x1A1E1E2E),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> vesselGlow([Color color = const Color(0x734ECDC4)]) => [
        BoxShadow(
          color: color,
          blurRadius: 18,
          spreadRadius: 2,
        ),
        const BoxShadow(
          color: Color(0x141E1E2E),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ];

  static const List<BoxShadow> vesselResting = [
    BoxShadow(
      color: Color(0x141E1E2E),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> pillBadge = [
    BoxShadow(
      color: Color(0x0F1E1E2E),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}
