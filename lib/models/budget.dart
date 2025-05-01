import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final int month;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Budget from a Firestore document
  factory Budget.fromMap(Map<String, dynamic> map, String documentId) {
    return Budget(
      id: documentId,
      userId: map['user_id'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      month: map['month'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Budget to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category': category,
      'amount': amount,
      'month': month,
      'year': year,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Return a copy of this Budget with the specified fields replaced
  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    int? month,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
