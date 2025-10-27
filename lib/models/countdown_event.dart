import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'countdown_event.g.dart';

@HiveType(typeId: 0)
class CountdownEvent {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime targetDate;

  @HiveField(3)
  final String timezone;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final String emoji;

  @HiveField(6)
  final bool isPinned;

  @HiveField(7)
  final String? shareSlug;

  @HiveField(8)
  final String? vanitySlug;

  @HiveField(9)
  final String? themeId;

  @HiveField(10)
  final DateTime createdAt;

  CountdownEvent({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.timezone,
    required this.colorValue,
    required this.emoji,
    this.isPinned = false,
    this.shareSlug,
    this.vanitySlug,
    this.themeId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Duration get timeRemaining => targetDate.difference(DateTime.now());
  bool get hasEnded => timeRemaining.isNegative;
  bool get isShared => shareSlug != null;

  Color get color => Color(colorValue);

  CountdownEvent copyWith({
    String? title,
    DateTime? targetDate,
    String? timezone,
    int? colorValue,
    String? emoji,
    bool? isPinned,
    String? shareSlug,
    String? vanitySlug,
    String? themeId,
  }) {
    return CountdownEvent(
      id: id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      timezone: timezone ?? this.timezone,
      colorValue: colorValue ?? this.colorValue,
      emoji: emoji ?? this.emoji,
      isPinned: isPinned ?? this.isPinned,
      shareSlug: shareSlug ?? this.shareSlug,
      vanitySlug: vanitySlug ?? this.vanitySlug,
      themeId: themeId ?? this.themeId,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetDate': targetDate.toIso8601String(),
        'timezone': timezone,
        'colorValue': colorValue,
        'emoji': emoji,
        'isPinned': isPinned,
        'shareSlug': shareSlug,
        'vanitySlug': vanitySlug,
        'themeId': themeId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CountdownEvent.fromJson(Map<String, dynamic> json) =>
      CountdownEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        targetDate: DateTime.parse(json['targetDate'] as String),
        timezone: json['timezone'] as String,
        colorValue: json['colorValue'] as int,
        emoji: json['emoji'] as String,
        isPinned: json['isPinned'] as bool? ?? false,
        shareSlug: json['shareSlug'] as String?,
        vanitySlug: json['vanitySlug'] as String?,
        themeId: json['themeId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
