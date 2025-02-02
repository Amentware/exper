import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String id;
  String categoryId; // Link to the category
  double amount;
  DateTime date;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}
