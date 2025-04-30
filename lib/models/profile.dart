import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String authUsersId;

  // Individual preferences instead of map
  final String defaultDateRange;
  final DateTime customStartDate;
  final DateTime customEndDate;
  final String currency;
  final String theme;
  final bool notificationsEnabled;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String icon;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.authUsersId,
    required this.defaultDateRange,
    required this.customStartDate,
    required this.customEndDate,
    required this.currency,
    required this.theme,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
    required this.icon,
  });

  // Create a ProfileModel from a Firestore document
  factory ProfileModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final Map<String, dynamic> preferences =
        data['preferences'] as Map<String, dynamic>? ?? {};

    return ProfileModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      authUsersId: data['auth_users_id'] ?? snapshot.id,

      // Extract individual preferences
      defaultDateRange: data['default_date_range'] as String? ?? 'month',
      customStartDate: data.containsKey('custom_start_date')
          ? (data['custom_start_date'] as Timestamp).toDate()
          : DateTime.now().subtract(const Duration(days: 30)),
      customEndDate: data.containsKey('custom_end_date')
          ? (data['custom_end_date'] as Timestamp).toDate()
          : DateTime.now(),
      currency: data['currency'] as String? ?? '₹',
      theme: data['theme'] as String? ?? 'light',
      notificationsEnabled: data['notification_enabled'] as bool? ?? true,

      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      icon: data['icon'] ?? 'default_profile',
    );
  }

  // Convert the model to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'auth_users_id': authUsersId,
      'default_date_range': defaultDateRange,
      'custom_start_date': Timestamp.fromDate(customStartDate),
      'custom_end_date': Timestamp.fromDate(customEndDate),
      'currency': currency,
      'theme': theme,
      'notification_enabled': notificationsEnabled,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'icon': icon,
    };
  }

  // Helper methods for determining date range
  DateTime get startDate {
    final now = DateTime.now();

    if (defaultDateRange == 'custom') {
      return customStartDate;
    }

    switch (defaultDateRange) {
      case 'month':
        return DateTime(now.year, now.month, 1);
      case 'quarter':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        return DateTime(now.year, (currentQuarter - 1) * 3 + 1, 1);
      case 'year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime.now().subtract(const Duration(days: 30));
    }
  }

  DateTime get endDate {
    final now = DateTime.now();

    if (defaultDateRange == 'custom') {
      return customEndDate;
    }

    switch (defaultDateRange) {
      case 'month':
        return DateTime(
            now.year, now.month + 1, 0); // Last day of current month
      case 'quarter':
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        return DateTime(now.year, currentQuarter * 3 + 1, 0);
      case 'year':
        return DateTime(now.year, 12, 31);
      default:
        return DateTime.now();
    }
  }

  // Create a copy of the model with updated fields
  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? authUsersId,
    String? defaultDateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? currency,
    String? theme,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? icon,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      authUsersId: authUsersId ?? this.authUsersId,
      defaultDateRange: defaultDateRange ?? this.defaultDateRange,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      icon: icon ?? this.icon,
    );
  }
}
