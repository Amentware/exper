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
        print('CATEGORY: No user ID found, cannot fetch categories');
        isLoading.value = false;
        return;
      }

      print('CATEGORY: Fetching categories for user $userId');

      // Simple query without ordering to avoid index requirement
      final querySnapshot = await _firestore
          .collection('categories')
          .where('user_id', isEqualTo: userId)
          // Removed orderBy to avoid index requirement
          .get(GetOptions(
              source: Source.serverAndCache)); // Use cache when available

      print('CATEGORY: Found ${querySnapshot.docs.length} categories');

      // If no categories exist for this user, create default ones
      if (querySnapshot.docs.isEmpty) {
        print('CATEGORY: Creating default categories since none exist');
        await createDefaultCategories(userId);
        return; // fetchCategories will be called again after defaults are created
      }

      final categoryList = querySnapshot.docs
          .map((doc) {
            try {
              print('CATEGORY: Processing ${doc.id} - ${doc.data()}');
              return Category.fromMap(doc.data(), doc.id);
            } catch (e) {
              print('CATEGORY: Error parsing category ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Category>()
          .toList();

      print('CATEGORY: Successfully parsed ${categoryList.length} categories');

      // Sort categories by name client-side instead of in the query
      categoryList.sort((a, b) => a.name.compareTo(b.name));

      // Clear existing categories and update with new data
      categories.clear();
      categories.addAll(categoryList);

      // Filter categories by type
      filterCategoriesByType();

      // Extract category names for dropdowns
      categoryNames.clear();
      categoryNames.add('All Categories');
      categoryNames.addAll(categoryList.map((category) => category.name));

      print('CATEGORY: Categories available: ${categories.length}');
      print(
          'CATEGORY: Category names for dropdown: ${categoryNames.join(', ')}');

      // Ensure income categories are properly marked
      _ensureIncomeCategories();
    } catch (e) {
      print('CATEGORY: Error fetching categories: $e');
      print('CATEGORY: Stack trace: ${StackTrace.current}');
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

  // Get the type of a category (expense or income)
  String getCategoryType(String categoryName) {
    try {
      final category = getCategoryByName(categoryName);
      if (category != null) {
        return category.type;
      }

      // Fallback logic for when category isn't found
      final nameLower = categoryName.trim().toLowerCase();
      final incomeKeywords = [
        'income',
        'salary',
        'revenue',
        'wage',
        'earnings',
        'stipend',
        'bonus'
      ];

      if (incomeKeywords.any((keyword) => nameLower.contains(keyword))) {
        return 'income';
      }

      // Default to expense if uncertain
      return 'expense';
    } catch (e) {
      return 'expense';
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
          colorText: Colors.white,
          backgroundColor: Colors.black,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
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
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      print('Error adding category: $e');
      Get.snackbar(
        'Error',
        'Failed to add category',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
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
            colorText: Colors.white,
            backgroundColor: Colors.black,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(10),
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
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      print('Error updating category: $e');
      Get.snackbar(
        'Error',
        'Failed to update category',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> hasTransactions(String categoryId) async {
    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) return false;

      final querySnapshot = await _firestore
          .collection('transactions')
          .where('user_id', isEqualTo: userId)
          .where('category_id', isEqualTo: categoryId)
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
      final hasLinkedTransactions = await hasTransactions(category.id);
      if (hasLinkedTransactions) {
        Get.snackbar(
          'Error',
          'Cannot delete category that has transactions',
          colorText: Colors.white,
          backgroundColor: Colors.black,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
        isLoading.value = false;
        return;
      }

      await _firestore.collection('categories').doc(id).delete();
      await fetchCategories();

      Get.snackbar(
        'Success',
        'Category deleted successfully',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      print('Error deleting category: $e');
      Get.snackbar(
        'Error',
        'Failed to delete category',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create default categories if none exist
  Future<void> createDefaultCategories(String userId) async {
    try {
      print('CATEGORY: Creating default categories');
      final now = DateTime.now();

      // Default expense categories with icons
      final defaultExpenseCategories = [
        {'name': 'Food', 'icon': 'food'},
        {'name': 'Petrol', 'icon': 'petrol'},
        {'name': 'Entertainment', 'icon': 'entertainment'},
        {'name': 'Rent', 'icon': 'rent'},
        {'name': 'Utilities', 'icon': 'utilities'},
        {'name': 'Personal', 'icon': 'personal'},
        {'name': 'Shopping', 'icon': 'shopping'},
        {'name': 'Other', 'icon': 'other'}
      ];

      // Default income categories with icons
      final defaultIncomeCategories = [
        {'name': 'Salary', 'icon': 'salary'},
      ];

      // Create a batch for better performance and atomicity
      final batch = _firestore.batch();

      // Add expense categories
      for (var catInfo in defaultExpenseCategories) {
        try {
          final docRef = _firestore.collection('categories').doc();
          final category = Category(
            id: docRef.id,
            name: catInfo['name']!,
            type: 'expense',
            userId: userId,
            icon: catInfo['icon']!,
            createdAt: now,
            updatedAt: now,
          );
          batch.set(docRef, category.toMap());
          print('CATEGORY: Added expense category: ${catInfo['name']}');
        } catch (e) {
          print(
              'CATEGORY: Error adding expense category ${catInfo['name']}: $e');
        }
      }

      // Add income categories
      for (var catInfo in defaultIncomeCategories) {
        try {
          final docRef = _firestore.collection('categories').doc();
          final category = Category(
            id: docRef.id,
            name: catInfo['name']!,
            type: 'income',
            userId: userId,
            icon: catInfo['icon']!,
            createdAt: now,
            updatedAt: now,
          );
          batch.set(docRef, category.toMap());
          print('CATEGORY: Added income category: ${catInfo['name']}');
        } catch (e) {
          print(
              'CATEGORY: Error adding income category ${catInfo['name']}: $e');
        }
      }

      // Commit the batch
      await batch.commit();

      print('CATEGORY: Default categories created successfully');
      // Fetch the newly created categories
      try {
        await fetchCategories();
      } catch (e) {
        print('CATEGORY: Error fetching categories after creation: $e');
      }
    } catch (e) {
      print('CATEGORY: Error creating default categories: $e');
      print('CATEGORY: Stack trace: ${StackTrace.current}');
    }
  }

  // New method to ensure income categories are properly marked
  void _ensureIncomeCategories() {
    // Check for "Salary" category and make sure it's type is "income"
    final salaryCategories = categories.where((cat) =>
        cat.name.trim().toLowerCase() == "salary" ||
        cat.name.trim().toLowerCase().contains("salary"));

    for (var category in salaryCategories) {
      if (category.type != 'income') {
        // Fix incorrect type by updating the category
        updateCategory(category.id, {'type': 'income'});
        print('CATEGORY: Fixed Salary category type to income');
      }
    }

    // Check other common income categories
    final incomeKeywords = [
      'income',
      'salary',
      'revenue',
      'wage',
      'earnings',
      'stipend',
      'bonus'
    ];

    for (var category in categories) {
      final nameLower = category.name.trim().toLowerCase();
      bool shouldBeIncome =
          incomeKeywords.any((keyword) => nameLower.contains(keyword));

      if (shouldBeIncome && category.type != 'income') {
        // Fix incorrect type
        updateCategory(category.id, {'type': 'income'});
        print('CATEGORY: Fixed ${category.name} category type to income');
      }
    }
  }

  // Add this method after the other methods
  IconData getCategoryIcon(String? categoryId) {
    try {
      // If no category ID provided, return a default icon
      if (categoryId == null) {
        return Icons.category;
      }

      // Find the category
      final category = getCategoryById(categoryId);
      if (category == null) {
        return Icons.category;
      }

      // Map category names or icon string identifiers to appropriate Material icons
      final iconName = category.icon.isNotEmpty
          ? category.icon
          : category.name.toLowerCase();

      switch (iconName.toLowerCase()) {
        // Expense categories
        case 'food':
          return Icons.restaurant;
        case 'petrol':
        case 'gas':
        case 'fuel':
          return Icons.local_gas_station;
        case 'entertainment':
          return Icons.movie;
        case 'rent':
        case 'housing':
          return Icons.home;
        case 'utilities':
          return Icons.bolt;
        case 'personal':
          return Icons.person;
        case 'shopping':
          return Icons.shopping_cart;
        case 'other':
          return Icons.more_horiz;
        case 'transport':
        case 'transportation':
          return Icons.directions_bus;
        case 'travel':
          return Icons.flight;
        case 'healthcare':
        case 'medical':
          return Icons.local_hospital;
        case 'education':
          return Icons.school;
        case 'groceries':
          return Icons.local_grocery_store;

        // Income categories
        case 'salary':
        case 'wage':
        case 'earnings':
          return Icons.payments;
        case 'income':
          return Icons.attach_money;
        case 'bonus':
          return Icons.card_giftcard;
        case 'investment':
          return Icons.trending_up;

        // Default
        case 'default':
        default:
          // Return a generic icon for unknown cases
          return category.type == 'income'
              ? Icons.arrow_upward
              : Icons.arrow_downward;
      }
    } catch (e) {
      print('Error getting category icon: $e');
      return Icons.category;
    }
  }
}
