import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;
  String type; // income or expense
  List<String> subcategories; // List of subcategories

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.subcategories = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'subcategories': subcategories,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      subcategories: List<String>.from(map['subcategories'] ?? []),
    );
  }
}
