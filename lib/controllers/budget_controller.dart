import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../controllers/auth_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';

class BudgetController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final TransactionController _transactionController =
      Get.find<TransactionController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  // Reactive variables
  final budgets = <Budget>[].obs;
  final isLoading = false.obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  // Calculate remaining days in month
  int get remainingDaysInMonth {
    final now = DateTime.now();
    final lastDayOfMonth =
        DateTime(selectedYear.value, selectedMonth.value + 1, 0);
    return lastDayOfMonth.day - now.day + 1;
  }

  @override
  void onInit() {
    super.onInit();
    fetchBudgets();
  }

  // Fetch budgets for the selected month and year
  Future<void> fetchBudgets() async {
    isLoading.value = true;

    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // This query requires a composite index on Firestore:
      // Collection: budgets, Fields: user_id (Ascending), month (Ascending), year (Ascending)
      final querySnapshot = await _firestore
          .collection('budgets')
          .where('user_id', isEqualTo: userId)
          .where('month', isEqualTo: selectedMonth.value)
          .where('year', isEqualTo: selectedYear.value)
          .get(GetOptions(
              source: Source.serverAndCache)); // Use cache when available

      final budgetList = querySnapshot.docs
          .map((doc) {
            try {
              return Budget.fromMap(doc.data(), doc.id);
            } catch (e) {
              print('Error parsing budget ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Budget>() // Filter out nulls
          .toList();

      budgets.clear();
      budgets.addAll(budgetList);
    } catch (e) {
      print('Error fetching budgets: $e');
      // If there's an index error, suggest creating an index
      if (e.toString().contains('requires an index')) {
        print('Index error: Please create a composite index on Firestore:');
        print(
            'Collection: budgets, Fields: user_id (Ascending), month (Ascending), year (Ascending)');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Set the month and year and fetch budgets
  Future<void> setMonthYear(int month, int year) async {
    selectedMonth.value = month;
    selectedYear.value = year;
    await fetchBudgets();
  }

  // Add or update a budget using categoryId
  Future<void> setBudget(String categoryId, double amount) async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value?.uid;
      if (userId == null) return;

      // Check if budget already exists for this category ID, month, and year
      final existingBudgetQuery = await _firestore
          .collection('budgets')
          .where('user_id', isEqualTo: userId)
          .where('category_id', isEqualTo: categoryId)
          .where('month', isEqualTo: selectedMonth.value)
          .where('year', isEqualTo: selectedYear.value)
          .get();

      final now = DateTime.now();

      if (existingBudgetQuery.docs.isNotEmpty) {
        // Update existing budget
        final docId = existingBudgetQuery.docs.first.id;
        await _firestore.collection('budgets').doc(docId).update({
          'amount': amount,
          'updated_at': Timestamp.fromDate(now),
        });
      } else {
        // Create new budget
        final budget = Budget(
          id: '',
          userId: userId,
          categoryId: categoryId,
          amount: amount,
          month: selectedMonth.value,
          year: selectedYear.value,
          createdAt: now,
          updatedAt: now,
        );

        await _firestore.collection('budgets').add(budget.toMap());
      }

      // Refresh budgets
      await fetchBudgets();

      // Get category name for snackbar message
      String categoryName = 'Unknown';
      final category = _categoryController.getCategoryById(categoryId);
      if (category != null) {
        categoryName = category.name;
      }

      Get.snackbar(
        'Budget Updated',
        'Budget for $categoryName has been set',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      print('Error setting budget: $e');
      Get.snackbar(
        'Error',
        'Failed to set budget',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('budgets').doc(budgetId).delete();
      await fetchBudgets();

      Get.snackbar(
        'Budget Deleted',
        'Budget has been deleted successfully',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      print('Error deleting budget: $e');
      Get.snackbar(
        'Error',
        'Failed to delete budget',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get total budget amount for all categories
  double get totalBudget {
    if (budgets.isEmpty) return 0.0;
    return budgets.fold(0.0, (sum, budget) => sum + budget.amount);
  }

  // Get total spent amount across all expense categories
  double get totalSpent {
    double spent = 0.0;

    // Get all transactions for the current month
    final transactions = _transactionController.transactions.where((tx) {
      final txDate = tx.date;
      return txDate.month == selectedMonth.value &&
          txDate.year == selectedYear.value;
    }).toList();

    // Calculate spent amount only for expense categories that have a budget
    for (var budget in budgets) {
      final categoryTransactions = transactions
          .where((tx) =>
              tx.categoryId == budget.categoryId &&
              _categoryController.getCategoryType(tx.categoryId) == 'expense')
          .toList();

      spent += categoryTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
    }

    return spent;
  }

  // Get remaining budget amount
  double get remainingBudget {
    return totalBudget - totalSpent;
  }

  // Get daily budget based on remaining days in month
  double get dailyBudget {
    if (remainingDaysInMonth <= 0) return 0.0;
    return remainingBudget / remainingDaysInMonth;
  }

  // Get category-specific spent amount
  double getCategorySpent(String categoryId) {
    // Get transactions for the specific category in the current month/year
    final transactions = _transactionController.transactions
        .where((tx) =>
            tx.categoryId == categoryId &&
            tx.date.month == selectedMonth.value &&
            tx.date.year == selectedYear.value &&
            _categoryController.getCategoryType(categoryId) == 'expense')
        .toList();

    return transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Get budget for a specific category by ID
  Budget? getBudgetForCategoryId(String categoryId) {
    try {
      return budgets.firstWhere((budget) => budget.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get budget for a specific category by name (helper method for backwards compatibility)
  Budget? getBudgetForCategory(String categoryName) {
    try {
      // Find the category ID for the given name
      final category = _categoryController.getCategoryByName(categoryName);
      if (category == null) return null;

      // Get budget for the category ID
      return getBudgetForCategoryId(category.id);
    } catch (e) {
      return null;
    }
  }

  // Get top budget categories with spending data
  List<Map<String, dynamic>> getTopBudgetCategories({int limit = 3}) {
    try {
      final result = <Map<String, dynamic>>[];

      // For each budget
      for (var budget in budgets) {
        // Find the category for this budget
        final category = _categoryController.getCategoryById(budget.categoryId);
        final categoryName = category?.name ?? 'Unknown';

        // Check if we have transactions for this month
        final now = DateTime.now();
        final monthStart = DateTime(selectedYear.value, selectedMonth.value, 1);
        final monthEnd =
            DateTime(selectedYear.value, selectedMonth.value + 1, 0);

        // Calculate spent for this category
        double spent = 0.0;
        for (var transaction in _transactionController.transactions) {
          // Match by category ID and ensure transaction is in this month
          if (transaction.categoryId == budget.categoryId &&
              transaction.date
                  .isAfter(monthStart.subtract(Duration(days: 1))) &&
              transaction.date.isBefore(monthEnd.add(Duration(days: 1)))) {
            spent += transaction.amount;
          }
        }

        // Calculate progress percentage
        final progress = spent / budget.amount;

        // Add to result
        result.add({
          'category': categoryName,
          'spent': spent,
          'budget': budget.amount,
          'progress': progress,
        });
      }

      // Sort by progress (highest first)
      result.sort((a, b) =>
          (b['progress'] as double).compareTo(a['progress'] as double));

      // Take top X results
      return result.take(limit).toList();
    } catch (e) {
      print('Error getting top budget categories: $e');
      return [];
    }
  }

  // Get budget progress data for all categories
  List<Map<String, dynamic>> getCategoryBudgetProgress() {
    try {
      final result = <Map<String, dynamic>>[];

      // For each budget
      for (var budget in budgets) {
        // Find the category for this budget
        final category = _categoryController.getCategoryById(budget.categoryId);
        final categoryName = category?.name ?? 'Unknown';

        // Calculate spent for this category
        double spent = 0.0;
        for (var transaction in _transactionController.transactions) {
          if (transaction.categoryId == budget.categoryId &&
              transaction.date.month == selectedMonth.value &&
              transaction.date.year == selectedYear.value) {
            spent += transaction.amount;
          }
        }

        // Calculate progress
        final progress = spent / budget.amount;

        // Add to result
        result.add({
          'category': categoryName,
          'spent': spent,
          'budget': budget.amount,
          'progress': progress,
        });
      }

      // Sort by progress (highest first)
      result.sort((a, b) =>
          (b['progress'] as double).compareTo(a['progress'] as double));

      return result;
    } catch (e) {
      print('Error getting category budget progress: $e');
      return [];
    }
  }

  // Get a category ID from its name
  String getCategoryIdForName(String categoryName) {
    try {
      final category = _categoryController.getCategoryByName(categoryName);
      return category?.id ?? '';
    } catch (e) {
      print('Error getting category ID for name: $e');
      return '';
    }
  }
}
