import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

/// Frosted glassmorphic card container with backdrop blur and luminous border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.glassCard,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withOpacity(0.95),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
