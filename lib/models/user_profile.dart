import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  final bool isPro;

  @HiveField(1)
  final DateTime? proUnlockedAt;

  @HiveField(2)
  final String? proTransactionId;

  UserProfile({
    this.isPro = false,
    this.proUnlockedAt,
    this.proTransactionId,
  });

  UserProfile copyWith({
    bool? isPro,
    DateTime? proUnlockedAt,
    String? proTransactionId,
  }) {
    return UserProfile(
      isPro: isPro ?? this.isPro,
      proUnlockedAt: proUnlockedAt ?? this.proUnlockedAt,
      proTransactionId: proTransactionId ?? this.proTransactionId,
    );
  }
}
