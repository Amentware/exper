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

      final querySnapshot = await _firestore
          .collection('budgets')
          .where('user_id', isEqualTo: userId)
          .where('month', isEqualTo: selectedMonth.value)
          .where('year', isEqualTo: selectedYear.value)
          .get();

      final budgetList = querySnapshot.docs
          .map((doc) => Budget.fromMap(doc.data(), doc.id))
          .toList();

      budgets.clear();
      budgets.addAll(budgetList);
    } catch (e) {
      print('Error fetching budgets: $e');
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

  // Add or update a budget
  Future<void> setBudget(String category, double amount) async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value?.uid;
      if (userId == null) return;

      // Check if budget already exists for this category, month, and year
      final existingBudgetQuery = await _firestore
          .collection('budgets')
          .where('user_id', isEqualTo: userId)
          .where('category', isEqualTo: category)
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
          category: category,
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

      Get.snackbar(
        'Budget Updated',
        'Budget for $category has been set',
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
              tx.category == budget.category &&
              _categoryController.getCategoryType(tx.category) == 'expense')
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
  double getCategorySpent(String category) {
    // Get transactions for the specific category in the current month/year
    final transactions = _transactionController.transactions
        .where((tx) =>
            tx.category == category &&
            tx.date.month == selectedMonth.value &&
            tx.date.year == selectedYear.value &&
            _categoryController.getCategoryType(category) == 'expense')
        .toList();

    return transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Get budget for a specific category
  Budget? getBudgetForCategory(String category) {
    try {
      return budgets.firstWhere((budget) => budget.category == category);
    } catch (e) {
      return null;
    }
  }

  // Get list of categories with budget progress
  List<Map<String, dynamic>> getCategoryBudgetProgress() {
    final result = <Map<String, dynamic>>[];

    for (var budget in budgets) {
      final spent = getCategorySpent(budget.category);
      final progress = budget.amount > 0 ? (spent / budget.amount) : 0.0;

      result.add({
        'category': budget.category,
        'budget': budget.amount,
        'spent': spent,
        'remaining': budget.amount - spent,
        'progress': progress,
      });
    }

    // Sort by highest percentage used
    result.sort((a, b) => b['progress'].compareTo(a['progress']));

    return result;
  }

  // Get top budget categories by usage percentage
  List<Map<String, dynamic>> getTopBudgetCategories({int limit = 3}) {
    final progress = getCategoryBudgetProgress();
    return progress.take(limit).toList();
  }
}
