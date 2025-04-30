import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as models;
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/category_controller.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  final searchController = TextEditingController();
  final selectedDateRange = ''.obs;
  final transactions = <models.Transaction>[].obs;
  final filteredTransactions = <models.Transaction>[].obs;
  final isLoading = true.obs;

  final selectedCategory = 'All Categories'.obs;
  final selectedType = 'All Types'.obs;

  final types = ['All Types', 'Income', 'Expense'].obs;

  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;
  // Statistics
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final balance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Wait for profile controller to initialize
    ever(_profileController.profile, (_) => _fetchUserDateRange());

    // Initial fetch if profile is already loaded
    if (_profileController.profile.value != null) {
      _fetchUserDateRange();
    }
  }

  void _fetchUserDateRange() async {
    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) return;

      // Use ProfileController to get date range
      startDate.value = _profileController.startDate;
      endDate.value = _profileController.endDate;

      // Initialize date range display
      _initDateRange();
      // Fetch transactions based on the determined date range
      fetchTransactions();
    } catch (e) {
      print('Error setting user date range: $e');
      // Fall back to last 30 days
      startDate.value = DateTime.now().subtract(const Duration(days: 30));
      endDate.value = DateTime.now();
      _initDateRange();
      fetchTransactions();
    }
  }

  void _initDateRange() {
    // Format the date range for display
    final startFormatted = DateFormat('MMM dd, yyyy').format(startDate.value);
    final endFormatted = DateFormat('MMM dd, yyyy').format(endDate.value);
    selectedDateRange.value = '$startFormatted - $endFormatted';
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      print(
          'Fetching transactions for period: ${startDate.value} to ${endDate.value}');

      var query = _firestore
          .collection('transactions')
          .where('user_id', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate.value))
          .orderBy('date', descending: true);

      final querySnapshot = await query.get();
      print('Found ${querySnapshot.docs.length} transactions');

      final transactionList = querySnapshot.docs
          .map((doc) {
            try {
              return models.Transaction.fromMap(doc.data(), doc.id);
            } catch (e) {
              print('Error parsing transaction ${doc.id}: $e');
              print('Data: ${doc.data()}');
              return null;
            }
          })
          .whereType<models.Transaction>()
          .toList();

      transactions.clear();
      transactions.addAll(transactionList);

      // Apply filters to set initial filteredTransactions
      applyFilters();

      // Calculate statistics
      calculateStatistics();

      print('Loaded ${transactions.length} transactions successfully');
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    filteredTransactions.clear();

    var filtered = transactions.where((transaction) {
      // Apply category filter
      if (selectedCategory.value != 'All Categories' &&
          transaction.category != selectedCategory.value) {
        return false;
      }

      // Apply type filter based on category type
      if (selectedType.value != 'All Types') {
        // Find the category of this transaction
        final categoryMatches = _categoryController.categories
            .where((category) => category.name == transaction.category);

        if (categoryMatches.isNotEmpty) {
          final transactionCategory = categoryMatches.first;
          // Filter by type
          if (selectedType.value == 'Income' &&
              transactionCategory.type != 'income') {
            return false;
          } else if (selectedType.value == 'Expense' &&
              transactionCategory.type != 'expense') {
            return false;
          }
        } else {
          // If category not found, log for debugging
          print(
              'Category not found for transaction: ${transaction.id}, category: ${transaction.category}');

          // Default behavior: assume it's an expense if we can't determine type
          if (selectedType.value == 'Income') {
            return false;
          }
        }
      }

      // Apply search filter
      if (searchController.text.isNotEmpty) {
        final searchTerm = searchController.text.toLowerCase();
        return transaction.description.toLowerCase().contains(searchTerm) ||
            transaction.category.toLowerCase().contains(searchTerm);
      }

      return true;
    }).toList();

    filteredTransactions.addAll(filtered);
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void setType(String type) {
    selectedType.value = type;
    applyFilters();
  }

  Future<void> setDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    _initDateRange();

    // Save user preference for date range using ProfileController
    try {
      await _profileController.setDateRange(start, end);
    } catch (e) {
      print('Error saving date range preference: $e');
    }

    await fetchTransactions();
  }

  void searchTransactions(String query) {
    applyFilters();
  }

  Future<void> addTransaction(models.Transaction transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toMap());
      await fetchTransactions();
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('transactions').doc(id).update({
        ...data,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });

      await fetchTransactions();
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection('transactions').doc(id).delete();
      await fetchTransactions();
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  // Calculate income, expense, and balance
  void calculateStatistics() {
    double income = 0.0;
    double expense = 0.0;

    for (var transaction in transactions) {
      // Find category to determine transaction type
      final categoryMatches = _categoryController.categories
          .where((category) => category.name == transaction.category);

      if (categoryMatches.isNotEmpty) {
        final category = categoryMatches.first;
        if (category.type == 'income') {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
      } else {
        // If category not found, log for debugging
        print(
            'Category not found for statistics: ${transaction.id}, category: ${transaction.category}');

        // Default behavior: assume it's an expense if we can't determine type
        expense += transaction.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    balance.value = income - expense;
  }

  // Get transactions by category
  List<models.Transaction> getTransactionsByCategory(String categoryName) {
    return transactions.where((t) => t.category == categoryName).toList();
  }

  // Get transactions for a specific date
  List<models.Transaction> getTransactionsByDate(DateTime date) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(date);
    return transactions.where((t) {
      final transactionDate = DateFormat('yyyy-MM-dd').format(t.date);
      return transactionDate == dateFormatted;
    }).toList();
  }

  // Find a transaction by ID
  models.Transaction? getTransactionById(String id) {
    try {
      return transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Edit an existing transaction with a new Transaction object
  Future<void> editTransaction(
      String id, models.Transaction updatedTransaction) async {
    try {
      isLoading.value = true;
      await _firestore
          .collection('transactions')
          .doc(id)
          .update(updatedTransaction.toMap());
      await fetchTransactions();
    } catch (e) {
      print('Error editing transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Create a new transaction with details provided
  Future<void> createTransaction({
    required String description,
    required double amount,
    required String category,
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;
      final userId = _authController.user.value!.uid;
      final now = DateTime.now();

      final transaction = models.Transaction(
        id: '',
        userId: userId,
        description: description,
        amount: amount,
        category: category,
        date: date,
        createdAt: now,
        updatedAt: now,
      );

      await addTransaction(transaction);
    } catch (e) {
      print('Error creating transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Duplicate an existing transaction
  Future<void> duplicateTransaction(String id) async {
    try {
      isLoading.value = true;
      final transaction = getTransactionById(id);
      if (transaction != null) {
        final now = DateTime.now();
        final duplicatedTransaction = models.Transaction(
          id: '',
          userId: transaction.userId,
          description: '${transaction.description} (Copy)',
          amount: transaction.amount,
          category: transaction.category,
          date: now,
          createdAt: now,
          updatedAt: now,
        );

        await addTransaction(duplicatedTransaction);
      }
    } catch (e) {
      print('Error duplicating transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get summary of transactions grouped by category
  Map<String, double> getCategorySummary() {
    final Map<String, double> summary = {};

    for (var transaction in filteredTransactions) {
      if (summary.containsKey(transaction.category)) {
        summary[transaction.category] =
            summary[transaction.category]! + transaction.amount;
      } else {
        summary[transaction.category] = transaction.amount;
      }
    }

    return summary;
  }
}
