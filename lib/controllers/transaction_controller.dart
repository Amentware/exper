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

      // Create an optimized query with proper filtering
      try {
        // This query requires a composite index on Firestore:
        // Collection: transactions, Fields: user_id (Ascending), date (Descending)
        var query = _firestore
            .collection('transactions')
            .where('user_id', isEqualTo: userId)
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value))
            .where('date',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate.value))
            .orderBy('date', descending: true);

        // Use cache when available for better performance
        final querySnapshot =
            await query.get(GetOptions(source: Source.serverAndCache));

        if (querySnapshot.docs.isEmpty) {
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

        final transactionList = querySnapshot.docs
            .map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return models.Transaction.fromMap(data, doc.id);
              } catch (e) {
                print('Error parsing transaction: $e');
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
        // If there's an index error, fall back to a simpler query with client-side filtering
        if (e.toString().contains('requires an index')) {
          print('Index error: $e');
          print('Falling back to simpler query with client-side filtering');

          // Simpler query without complex filtering
          var simpleQuery = _firestore
              .collection('transactions')
              .where('user_id', isEqualTo: userId)
              .orderBy('date', descending: true);

          final querySnapshot = await simpleQuery.get();

          // Client-side date filtering
          final filteredDocs = querySnapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('date') && data['date'] is Timestamp) {
              final docDate = (data['date'] as Timestamp).toDate();
              return docDate.isAfter(
                      startDate.value.subtract(const Duration(days: 1))) &&
                  docDate.isBefore(endDate.value.add(const Duration(days: 1)));
            }
            return false;
          }).toList();

          final transactionList = filteredDocs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  return models.Transaction.fromMap(data, doc.id);
                } catch (e) {
                  print('Error parsing transaction: $e');
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
        } else {
          // For other errors, rethrow
          throw e;
        }
      }
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
            transaction.categoryId != selectedCategory.value) {
          return false;
        }

        // Apply type filter based on category type
        if (selectedType.value != 'All Types') {
          bool isIncome = _isIncomeCategory(transaction.categoryId);

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
          final category = transaction.categoryId?.toLowerCase() ?? '';
          final categoryName =
              getCategoryNameById(transaction.categoryId).toLowerCase();

          // Check if search term appears in description or category
          return description.contains(searchTerm) ||
              category.contains(searchTerm) ||
              categoryName.contains(searchTerm);
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
      isLoading.value = true;

      final docRef =
          await _firestore.collection('transactions').add(transaction.toMap());

      print('Transaction added successfully with ID: ${docRef.id}');

      // Reload transactions to update UI
      await fetchTransactions();
    } catch (e) {
      print('Error adding transaction: $e');
      throw e;
    } finally {
      isLoading.value = false;
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
  bool _isIncomeCategory(String categoryId) {
    try {
      // Check the category type using the category controller
      return _categoryController.getCategoryById(categoryId)?.type == 'income';
    } catch (e) {
      // Default to false (expense) if there's an error
      return false;
    }
  }

  // Calculate income, expense, and balance
  void calculateStatistics() {
    try {
      double income = 0.0;
      double expense = 0.0;

      for (var transaction in filteredTransactions) {
        final categoryType = getCategoryTypeById(transaction.categoryId);

        if (categoryType == 'income') {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
      }

      totalIncome.value = income;
      totalExpense.value = expense;
      balance.value = income - expense;
    } catch (e) {
      print('Error calculating statistics: $e');
    }
  }

  // Get transactions by category
  List<models.Transaction> getTransactionsByCategory(String categoryName) {
    return transactions.where((t) => t.categoryId == categoryName).toList();
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
    required String categoryId,
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
        categoryId: categoryId,
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
          categoryId: transaction.categoryId,
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
      if (summary.containsKey(transaction.categoryId)) {
        summary[transaction.categoryId] =
            summary[transaction.categoryId]! + transaction.amount;
      } else {
        summary[transaction.categoryId] = transaction.amount;
      }
    }

    return summary;
  }

  // Helper method to get category name from ID
  String getCategoryNameById(String categoryId) {
    try {
      final category = _categoryController.getCategoryById(categoryId);
      return category?.name ?? 'Unknown';
    } catch (e) {
      print('Error getting category name: $e');
      return 'Unknown';
    }
  }

  // Helper method to get category type from ID
  String getCategoryTypeById(String categoryId) {
    try {
      final category = _categoryController.getCategoryById(categoryId);
      if (category != null) {
        return category.type;
      }

      // Default to expense if category not found
      return 'expense';
    } catch (e) {
      print('Error getting category type: $e');
      return 'expense';
    }
  }

  // Clear cache for transactions (for data refresh)
  Future<void> clearTransactionsCache() async {
    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) return;

      isLoading.value = true;
      update();

      // Fetch fresh data from server
      await fetchTransactions();

      print('Transactions cache cleared and refreshed');
    } catch (e) {
      print('Error clearing transactions cache: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
