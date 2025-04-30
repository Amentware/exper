import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/category.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final categories = <Category>[].obs;
  final categoryNames = <String>[].obs;
  final isLoading = false.obs;
  final selectedCategoryType = 'expense'.obs; // For filtering by type

  // Categories filtered by type
  final expenseCategories = <Category>[].obs;
  final incomeCategories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value?.uid;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final querySnapshot = await _firestore
          .collection('categories')
          .where('user_id', isEqualTo: userId)
          .get();

      final categoryList = querySnapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();

      categories.clear();
      categories.addAll(categoryList);

      // Filter categories by type
      filterCategoriesByType();

      // Extract category names for dropdowns
      categoryNames.clear();
      categoryNames.add('All Categories');
      categoryNames.addAll(categoryList.map((category) => category.name));
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter categories by expense/income type
  void filterCategoriesByType() {
    expenseCategories.clear();
    incomeCategories.clear();

    for (var category in categories) {
      if (category.type == 'expense') {
        expenseCategories.add(category);
      } else if (category.type == 'income') {
        incomeCategories.add(category);
      }
    }
  }

  // Get categories filtered by selected type
  List<Category> getFilteredCategories() {
    return categories
        .where((cat) => cat.type == selectedCategoryType.value)
        .toList();
  }

  // Get category names filtered by selected type
  List<String> getFilteredCategoryNames() {
    return getFilteredCategories().map((cat) => cat.name).toList();
  }

  // Set category type filter
  void setCategoryType(String type) {
    selectedCategoryType.value = type;
  }

  // Get a single category by name
  Category? getCategoryByName(String name) {
    try {
      return categories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get a single category by ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if a category exists with the same name
  bool categoryExists(String name) {
    return categories
        .any((cat) => cat.name.toLowerCase() == name.toLowerCase());
  }

  Future<void> addCategory(String name, String type, String icon) async {
    try {
      isLoading.value = true;

      // Check if category already exists
      if (categoryExists(name)) {
        Get.snackbar(
          'Error',
          'A category with this name already exists',
          colorText: Colors.black,
          backgroundColor: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final userId = _authController.user.value?.uid;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final now = DateTime.now();

      // Create a new document with auto-generated ID
      final docRef = _firestore.collection('categories').doc();

      final category = Category(
        id: docRef.id,
        name: name,
        type: type,
        userId: userId,
        icon: icon,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(category.toMap());
      await fetchCategories();

      Get.snackbar(
        'Success',
        'Category added successfully',
        colorText: Colors.black,
        backgroundColor: Colors.white,
      );
    } catch (e) {
      print('Error adding category: $e');
      Get.snackbar(
        'Error',
        'Failed to add category',
        colorText: Colors.black,
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;

      // Check if updating name and if it conflicts with existing category
      if (data.containsKey('name')) {
        final newName = data['name'] as String;
        final existingCategories = categories.where((cat) =>
            cat.id != id && cat.name.toLowerCase() == newName.toLowerCase());

        if (existingCategories.isNotEmpty) {
          Get.snackbar(
            'Error',
            'A category with this name already exists',
            colorText: Colors.black,
            backgroundColor: Colors.white,
          );
          isLoading.value = false;
          return;
        }
      }

      await _firestore.collection('categories').doc(id).update({
        ...data,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });

      await fetchCategories();

      Get.snackbar(
        'Success',
        'Category updated successfully',
        colorText: Colors.black,
        backgroundColor: Colors.white,
      );
    } catch (e) {
      print('Error updating category: $e');
      Get.snackbar(
        'Error',
        'Failed to update category',
        colorText: Colors.black,
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> hasTransactions(String categoryName) async {
    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) return false;

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('user_id', isEqualTo: userId)
          .where('category', isEqualTo: categoryName)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if category has transactions: $e');
      return false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      isLoading.value = true;

      // Get category by ID
      final category = getCategoryById(id);
      if (category == null) {
        isLoading.value = false;
        return;
      }

      // Check if category has transactions
      final hasLinkedTransactions = await hasTransactions(category.name);
      if (hasLinkedTransactions) {
        Get.snackbar(
          'Error',
          'Cannot delete category that has transactions',
          colorText: Colors.black,
          backgroundColor: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      await _firestore.collection('categories').doc(id).delete();
      await fetchCategories();

      Get.snackbar(
        'Success',
        'Category deleted successfully',
        colorText: Colors.black,
        backgroundColor: Colors.white,
      );
    } catch (e) {
      print('Error deleting category: $e');
      Get.snackbar(
        'Error',
        'Failed to delete category',
        colorText: Colors.black,
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createDefaultCategories() async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value?.uid;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final now = DateTime.now();

      // Default categories with type and icon
      final defaultCategories = [
        {'name': 'Food', 'type': 'expense', 'icon': 'shopping-cart'},
        {'name': 'Transportation', 'type': 'expense', 'icon': 'car'},
        {'name': 'Entertainment', 'type': 'expense', 'icon': 'tag'},
        {'name': 'Rent', 'type': 'expense', 'icon': 'tag'},
        {'name': 'Salary', 'type': 'income', 'icon': 'tag'},
        {'name': 'Petrol', 'type': 'expense', 'icon': 'car'},
        {'name': 'EMI', 'type': 'expense', 'icon': 'tag'},
        {'name': 'Shopping', 'type': 'expense', 'icon': 'shopping-cart'},
        {'name': 'Bills', 'type': 'expense', 'icon': 'tag'},
      ];

      // Create a batch to add multiple documents efficiently
      final batch = FirebaseFirestore.instance.batch();

      for (var category in defaultCategories) {
        // Create a new document reference with a UUID
        final docRef = _firestore.collection('categories').doc();

        // Add to batch
        batch.set(docRef, {
          'id': docRef.id,
          'name': category['name'],
          'type': category['type'],
          'user_id': userId,
          'icon': category['icon'],
          'created_at': Timestamp.fromDate(now),
          'updated_at': Timestamp.fromDate(now),
        });
      }

      // Commit the batch
      await batch.commit();

      // Refresh categories list
      await fetchCategories();
    } catch (e) {
      print('Error creating default categories: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
