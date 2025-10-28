import 'package:flutter/material.dart';
import '../app/app_colors.dart';

/// iOS-style app logo with rounded corners and shadow
/// Placeholder logo with calendar icon until final design is ready
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = size * 0.2167; // iOS standard ratio (26/120)

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: size * 0.167, // Proportional to size
                  spreadRadius: size * 0.017,
                  offset: Offset(0, size * 0.067),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          Icons.event_available_rounded,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}
