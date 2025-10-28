import 'dart:async';
import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_constants.dart';
import '../app/app_strings.dart';
import '../models/countdown_event.dart';
import '../utils/helper_functions.dart';

/// Isolated countdown display widget that updates every second
/// without affecting parent widget's scroll position
class CountdownDisplay extends StatefulWidget {
  const CountdownDisplay({super.key, required this.event});

  final CountdownEvent event;

  @override
  State<CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<CountdownDisplay> {
  Timer? _timer;
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  double progressPercentage = 0.0;
  bool hasEnded = false;

  @override
  void initState() {
    super.initState();
    _calculateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _calculateCountdown();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateCountdown() {
    final now = DateTime.now();
    final target = widget.event.targetDate;
    final created = widget.event.createdAt;

    if (now.isAfter(target)) {
      hasEnded = true;
      final diff = now.difference(target);
      days = diff.inDays;
      hours = diff.inHours.remainder(24);
      minutes = diff.inMinutes.remainder(60);
      seconds = diff.inSeconds.remainder(60);
    } else {
      hasEnded = false;
      final diff = target.difference(now);
      days = diff.inDays;
      hours = diff.inHours.remainder(24);
      minutes = diff.inMinutes.remainder(60);
      seconds = diff.inSeconds.remainder(60);
    }

    // Calculate progress percentage (countdown style: 100% -> 0%)
    if (created.isBefore(target)) {
      final totalDuration = target.difference(created).inSeconds;
      final remaining = target.difference(now).inSeconds;
      progressPercentage = (remaining / totalDuration * 100).clamp(0.0, 100.0);
    } else {
      progressPercentage = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in RepaintBoundary to isolate repaints and prevent scroll jumps
    return RepaintBoundary(
      child: Column(
        children: [
          // Countdown timer
          if (hasEnded)
            Text(
              AppStrings.eventEnded,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            _buildCountdown(context),
          const SizedBox(height: AppConstants.paddingLarge * 2),
          // Progress bar with percentage inside
          SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LinearProgressIndicator(
                    value: progressPercentage / 100,
                    minHeight: 32,
                    backgroundColor: AppColors.dividerDark,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.event.color,
                    ),
                  ),
                ),
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HelperFunctions.getTextColorForBackground(
                      widget.event.color,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final List<Widget> timeUnits = [];

    // Determine which unit gets the color (the highest/first one shown)
    final bool showDays = days > 0;
    final bool showHours = days > 0 || hours > 0;
    final bool showMinutes = days > 0 || hours > 0 || minutes > 0;

    if (showDays) {
      timeUnits.add(
        _buildTimeUnit(
          context,
          days.toString(),
          AppStrings.days,
          color: widget.event.color, // Days get color
          showDivider: false,
        ),
      );
    }
    if (showHours) {
      timeUnits.add(
        _buildTimeUnit(
          context,
          hours.toString().padLeft(2, '0'),
          AppStrings.hours,
          color: !showDays
              ? widget.event.color
              : null, // Hours get color if no days
          showDivider: true,
        ),
      );
    }
    if (showMinutes) {
      timeUnits.add(
        _buildTimeUnit(
          context,
          minutes.toString().padLeft(2, '0'),
          AppStrings.minutes,
          color: !showDays && !showHours
              ? widget.event.color
              : null, // Minutes get color if no days/hours
          showDivider: true,
        ),
      );
    }
    timeUnits.add(
      _buildTimeUnit(
        context,
        seconds.toString().padLeft(2, '0'),
        AppStrings.seconds,
        color: !showDays && !showHours && !showMinutes
            ? widget.event.color
            : null, // Seconds get color if nothing else
        showDivider: timeUnits.isNotEmpty,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 0,
        runSpacing: AppConstants.paddingMedium,
        children: timeUnits,
      ),
    );
  }

  Widget _buildTimeUnit(
    BuildContext context,
    String value,
    String label, {
    Color? color,
    required bool showDivider,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Leading divider (if not first item)
        if (showDivider) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: 2,
              height: 70,
              color: AppColors.dividerDark,
            ),
          ),
        ],
        // Time unit
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 64,
                  height: 1.0,
                  color: color,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
