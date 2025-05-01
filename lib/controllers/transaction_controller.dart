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

    // Wait for the CategoryController to fully load categories
    ever(_categoryController.categories, (_) {
      if (_profileController.profile.value != null) {
        applyFilters();
        calculateStatistics();
      }
    });

    // Ensure categories are loaded before transaction calculations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force refresh categories to ensure income categories are properly marked
      _categoryController.fetchCategories().then((_) {
        // After categories are loaded, fetch transactions
        if (_profileController.profile.value != null) {
          _fetchUserDateRange();
        }
      });
    });
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
    update(); // Update to show loading indicator

    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) {
        isLoading.value = false;
        update();
        return;
      }

      // First, check if there are any transactions for this user at all (no date filtering)
      var allTransactionsQuery = _firestore
          .collection('transactions')
          .where('user_id', isEqualTo: userId);

      var allTransactionsSnapshot = await allTransactionsQuery.get();

      if (allTransactionsSnapshot.docs.isEmpty) {
        transactions.clear();
        filteredTransactions.clear();
        // Explicitly reset statistics when no transactions exist
        totalIncome.value = 0.0;
        totalExpense.value = 0.0;
        balance.value = 0.0;
        isLoading.value = false;
        update();
        return;
      }

      List<QueryDocumentSnapshot> transactionDocs = [];

      try {
        // Try with date filtering - requires Firebase index
        var query = _firestore
            .collection('transactions')
            .where('user_id', isEqualTo: userId)
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value))
            .where('date',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate.value))
            .orderBy('date', descending: true);

        final querySnapshot = await query.get();
        transactionDocs = querySnapshot.docs;
      } catch (e) {
        // Check if this is an index error
        if (e.toString().contains('requires an index')) {
          // Use client-side filtering as fallback when index is missing
          transactionDocs = allTransactionsSnapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('date') && data['date'] is Timestamp) {
              final docDate = (data['date'] as Timestamp).toDate();
              return docDate
                      .isAfter(startDate.value.subtract(Duration(days: 1))) &&
                  docDate.isBefore(endDate.value.add(Duration(days: 1)));
            }
            return false;
          }).toList();

          // Sort manually since we can't use orderBy
          transactionDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTimestamp = aData['date'] as Timestamp;
            final bTimestamp = bData['date'] as Timestamp;

            // Compare using milliseconds since epoch to include both date and time
            return bTimestamp.millisecondsSinceEpoch
                .compareTo(aTimestamp.millisecondsSinceEpoch);
          });
        } else {
          // For other errors, rethrow
          throw e;
        }
      }

      final transactionList = transactionDocs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return models.Transaction.fromMap(data, doc.id);
            } catch (e) {
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
    } catch (e) {
      // Keep this for error handling
      print('ERROR FETCHING TRANSACTIONS: $e');
      // Reset statistics on error
      totalIncome.value = 0.0;
      totalExpense.value = 0.0;
      balance.value = 0.0;
      update();
    } finally {
      isLoading.value = false;
      update(); // Update UI after loading is complete
    }
  }

  void applyFilters() {
    try {
      filteredTransactions.clear();

      var filtered = transactions.where((transaction) {
        // Apply category filter
        if (selectedCategory.value != 'All Categories' &&
            transaction.category != selectedCategory.value) {
          return false;
        }

        // Apply type filter based on category type
        if (selectedType.value != 'All Types') {
          bool isIncome = _isIncomeCategory(transaction.category);

          if (selectedType.value == 'Income' && !isIncome) {
            return false;
          } else if (selectedType.value == 'Expense' && isIncome) {
            return false;
          }
        }

        // Apply search filter
        if (searchController.text.isNotEmpty) {
          final searchTerm = searchController.text.toLowerCase();
          // Safely handle null or empty fields with null-aware operators
          final description = transaction.description?.toLowerCase() ?? '';
          final category = transaction.category?.toLowerCase() ?? '';

          // Check if search term appears in description or category
          return description.contains(searchTerm) ||
              category.contains(searchTerm);
        }

        return true;
      }).toList();

      // Ensure transactions remain sorted by date (newest first)
      filtered.sort((a, b) {
        // First compare by date
        final dateComparison = b.date.compareTo(a.date);

        // If dates are the same (same day), compare by created_at timestamp if available
        if (dateComparison == 0) {
          // Compare created_at timestamps if they exist
          if (a.createdAt != null && b.createdAt != null) {
            return b.createdAt!.compareTo(a.createdAt!);
          }
          // If one has createdAt and the other doesn't, prioritize the one with createdAt
          if (a.createdAt != null) return -1;
          if (b.createdAt != null) return 1;
        }

        return dateComparison;
      });

      filteredTransactions.addAll(filtered);

      // Notify GetBuilder widgets to update
      update();
    } catch (e) {
      print('Error applying filters: $e');
      // Reset to all transactions in case of error
      filteredTransactions.clear();
      filteredTransactions.addAll(transactions);
      update();
    }
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
    try {
      print(
          'TransactionController: Setting date range from ${start.toString()} to ${end.toString()}');

      // Update local state first
      startDate.value = start;
      endDate.value = end;
      _initDateRange();

      // Save user preference for date range using ProfileController
      try {
        await _profileController.setDateRange(start, end);
      } catch (e) {
        print('Error saving date range preference to profile: $e');
        // Continue even if profile save fails
      }

      // Fetch transactions with the new date range
      await fetchTransactions();
    } catch (e) {
      print('Error in setDateRange: $e');
      // Fallback to a safe date range if there's an error
      startDate.value = DateTime.now().subtract(const Duration(days: 30));
      endDate.value = DateTime.now();
      _initDateRange();

      // Try to fetch transactions with fallback dates
      try {
        await fetchTransactions();
      } catch (innerError) {
        print('Failed to fetch transactions with fallback dates: $innerError');
      }
    }
  }

  // New method to filter transactions locally by date range without updating Firebase
  Future<void> filterByDateRangeLocally(DateTime start, DateTime end) async {
    try {
      print(
          'TransactionController: Filtering locally by date range from ${start.toString()} to ${end.toString()}');

      // Update local state
      startDate.value = start;
      endDate.value = end;
      _initDateRange();

      // Apply filters but don't save to Firebase or fetch new data
      applyFilters();
    } catch (e) {
      print('Error in filterByDateRangeLocally: $e');
    }
  }

  void searchTransactions(String query) {
    try {
      // Apply all filters with the updated search term
      applyFilters();
    } catch (e) {
      print('Error during search: $e');
      // Recover from error by resetting search
      if (searchController.text.isNotEmpty) {
        searchController.clear();
        applyFilters();
      }
    }
  }

  Future<void> addTransaction(models.Transaction transaction) async {
    try {
      // Convert the transaction to a map but explicitly use category_id field for compatibility
      Map<String, dynamic> transactionData = transaction.toMap();

      // Store the category value in both fields for backward compatibility
      transactionData['category_id'] = transaction.category;

      await _firestore.collection('transactions').add(transactionData);

      // Ensure the transactions list is refreshed completely
      await fetchTransactions();

      // Apply filters to update filtered transactions
      applyFilters();

      // Calculate statistics
      calculateStatistics();

      // Force update to ensure UI reflects changes
      update();
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

      // Check if there are no more transactions and reset statistics
      if (transactions.isEmpty) {
        totalIncome.value = 0.0;
        totalExpense.value = 0.0;
        balance.value = 0.0;
        update();
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }

  // Helper method to determine if a category is an income category
  bool _isIncomeCategory(String categoryName) {
    // First check the category controller
    final categoryMatches = _categoryController.categories.where((category) =>
        category.name.trim().toLowerCase() ==
        categoryName.trim().toLowerCase());

    if (categoryMatches.isNotEmpty) {
      return categoryMatches.first.type == 'income';
    }

    // Fallback heuristic for salary and income categories
    final lowerName = categoryName.trim().toLowerCase();
    final incomeKeywords = [
      'income',
      'salary',
      'revenue',
      'wage',
      'earnings',
      'stipend',
      'bonus'
    ];
    return incomeKeywords.any((keyword) => lowerName.contains(keyword));
  }

  // Calculate income, expense, and balance
  void calculateStatistics() {
    double income = 0.0;
    double expense = 0.0;

    // Only calculate if there are transactions
    if (transactions.isNotEmpty) {
      for (var transaction in transactions) {
        if (_isIncomeCategory(transaction.category)) {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
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
