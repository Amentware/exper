import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final DateTime date;
  final String description;
  final String category; // Using category name directly
  final double amount; // Positive amount (not sign-dependent on expense/income)
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'description': description,
      'amount': amount,
      'category': category, // Save as category (not category_id)
      'date': Timestamp.fromDate(date),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, String documentId) {
    return Transaction(
      id: documentId,
      userId: map['user_id'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      // Handle both category and category_id fields for backward compatibility
      category: map['category'] ?? map['category_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
    );
  }
}
