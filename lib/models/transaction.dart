import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String userId;
  final DateTime date;
  final String description;
  final String category; // Using category name directly
  final double amount; // Positive amount (not sign-dependent on expense/income)
  final DateTime createdAt;
  final DateTime updatedAt;

  // Add a getter for safely formatted amount with thousands separators
  String get formattedAmount {
    try {
      // Create a number formatter with thousands separators
      final formatter = NumberFormat('#,##0', 'en_IN');
      return formatter.format(amount);
    } catch (e) {
      // Fallback for error cases
      return amount.toStringAsFixed(0);
    }
  }

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
    try {
      // Handle user_id field
      final userId = map['user_id'] ?? '';

      // Handle description field
      final description = map['description'] ?? '';

      // Handle amount field
      double amount;
      if (map['amount'] is num) {
        amount = (map['amount'] as num).toDouble();
      } else {
        print('WARNING: Invalid amount format: ${map['amount']}');
        amount = 0.0;
      }

      // Handle category/category_id field
      final category = map['category'] ?? map['category_id'] ?? '';

      // Handle date field
      DateTime date;
      if (map['date'] is Timestamp) {
        date = (map['date'] as Timestamp).toDate();
      } else {
        print('WARNING: Invalid date format: ${map['date']}');
        date = DateTime.now();
      }

      // Handle created_at field
      DateTime createdAt;
      if (map['created_at'] is Timestamp) {
        createdAt = (map['created_at'] as Timestamp).toDate();
      } else {
        print('WARNING: Invalid created_at format: ${map['created_at']}');
        createdAt = DateTime.now();
      }

      // Handle updated_at field
      DateTime updatedAt;
      if (map['updated_at'] is Timestamp) {
        updatedAt = (map['updated_at'] as Timestamp).toDate();
      } else {
        print('WARNING: Invalid updated_at format: ${map['updated_at']}');
        updatedAt = DateTime.now();
      }

      return Transaction(
        id: documentId,
        userId: userId,
        description: description,
        amount: amount,
        category: category,
        date: date,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('ERROR creating Transaction from map: $e');
      print('Document ID: $documentId');
      print('Map data: $map');
      rethrow;
    }
  }
}
