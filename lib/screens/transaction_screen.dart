import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class TransactionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final ProfileController _profileController = Get.find<ProfileController>();

  final searchController = TextEditingController();
  final selectedDateRange = ''.obs;
  final transactions = <Transaction>[].obs;
  final filteredTransactions = <Transaction>[].obs;
  final isLoading = true.obs;

  final categories = <String>[].obs;
  final selectedCategory = 'All Categories'.obs;
  final selectedType = 'All Types'.obs;

  final types = ['All Types', 'Income', 'Expense'].obs;

  final startDate = DateTime.now().subtract(const Duration(days: 30)).obs;
  final endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _fetchUserDateRange();
    fetchCategories();
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
      // Fetch data based on the determined date range
      fetchCategories();
      fetchTransactions();
    } catch (e) {
      print('Error setting user date range: $e');
      // Fall back to last 30 days
      startDate.value = DateTime.now().subtract(const Duration(days: 30));
      endDate.value = DateTime.now();
      _initDateRange();
      fetchCategories();
      fetchTransactions();
    }
  }

  void _initDateRange() {
    // Format the date range for display
    final startFormatted = DateFormat('MMM dd, yyyy').format(startDate.value);
    final endFormatted = DateFormat('MMM dd, yyyy').format(endDate.value);
    selectedDateRange.value = '$startFormatted - $endFormatted';
  }

  Future<void> fetchCategories() async {
    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('categories')
          .where('user_id', isEqualTo: userId)
          .get();

      final categorySet = <String>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final category = data['name']?.toString() ?? '';
        if (category.isNotEmpty) {
          categorySet.add(category);
        }
      }

      categories.clear();
      categories.add('All Categories');
      categories.addAll(categorySet);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final userId = _authController.user.value?.uid;
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      var query = _firestore
          .collection('transactions')
          .where('user_id', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate.value))
          .orderBy('date', descending: true);

      final querySnapshot = await query.get();

      final transactionList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Transaction(
          id: doc.id,
          userId: data['user_id'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          description: data['description'] ?? '',
          category: data['category_id'] ?? '',
          amount: (data['amount'] as num).toDouble(),
          createdAt: (data['created_at'] as Timestamp).toDate(),
          updatedAt: (data['updated_at'] as Timestamp).toDate(),
        );
      }).toList();

      transactions.clear();
      transactions.addAll(transactionList);

      // Apply filters to set initial filteredTransactions
      applyFilters();
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

      // Apply type filter
      if (selectedType.value == 'Income' && transaction.amount <= 0) {
        return false;
      } else if (selectedType.value == 'Expense' && transaction.amount > 0) {
        return false;
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

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _firestore.collection('transactions').add({
        'user_id': transaction.userId,
        'amount': transaction.amount,
        'description': transaction.description,
        'date': Timestamp.fromDate(transaction.date),
        'category_id': transaction.category,
        'created_at': Timestamp.fromDate(DateTime.now()),
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });

      await fetchCategories();
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
}

class Transaction {
  final String id;
  final String userId;
  final DateTime date;
  final String description;
  final String category;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

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
}

class TransactionScreen extends StatelessWidget {
  final controller = Get.put(TransactionController());

  TransactionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAddTransactionButton(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown('All Types'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFilterDropdown('All Categories'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDateRangePicker(),
              const SizedBox(height: 16),
              _buildTransactionTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddTransactionButton() {
    return InkWell(
      onTap: () {
        _showAddTransactionDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Add Transaction',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: const InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          controller.searchTransactions(value);
        },
      ),
    );
  }

  Widget _buildFilterDropdown(String title) {
    if (title == 'All Types') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedType.value,
            icon: const Icon(Icons.keyboard_arrow_down),
            isExpanded: true,
            isDense: true,
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.setType(newValue);
              }
            },
            items:
                controller.types.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Obx(
          () => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedCategory.value,
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: true,
              isDense: true,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.setCategory(newValue);
                }
              },
              items: controller.categories
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: Get.context!,
          initialDateRange: DateTimeRange(
            start: controller.startDate.value,
            end: controller.endDate.value,
          ),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: blueColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          controller.setDateRange(picked.start, picked.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Obx(() => Text(
                  controller.selectedDateRange.value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTable() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }

        if (controller.filteredTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.filteredTransactions[index];
                    return Dismissible(
                      key: Key(transaction.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text(
                                  "Are you sure you want to delete this transaction?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        controller.deleteTransaction(transaction.id);
                      },
                      child: InkWell(
                        onTap: () {
                          // Handle transaction selection
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('dd').format(transaction.date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM yyyy')
                                          .format(transaction.date),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  transaction.category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  transaction.amount < 0
                                      ? '-₹${transaction.amount.abs()}'
                                      : '₹${transaction.amount}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: transaction.amount < 0
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showAddTransactionDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();
    final currency = profileController.currency;

    // Get the list of categories for the dropdown
    final categories = controller.categories
        .where((category) => category != 'All Categories')
        .toList();
    final selectedCategory =
        Rx<String?>(categories.isNotEmpty ? categories.first : null);

    // Create a flag for transaction type (expense/income)
    final isExpense = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'What was this for?',
                      fillColor: Colors.grey[100],
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: '0.00',
                            fillColor: Colors.grey[100],
                            filled: true,
                            prefixText: '$currency ',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => isExpense.value = true,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isExpense.value
                                      ? blueColor
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: isExpense.value
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => isExpense.value = false,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isExpense.value
                                      ? blueColor
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    color: !isExpense.value
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory.value,
                        hint: const Text('Select Category'),
                        isExpanded: true,
                        items: categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategory.value = value;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: blueColor,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateController.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (descriptionController.text.isEmpty ||
                              amountController.text.isEmpty ||
                              selectedCategory.value == null) {
                            Get.snackbar(
                              'Error',
                              'Please fill all fields',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          // Parse the amount
                          final amountValue =
                              double.tryParse(amountController.text);
                          if (amountValue == null) {
                            Get.snackbar(
                              'Error',
                              'Please enter a valid amount',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          // Apply sign based on transaction type
                          final amount = isExpense.value
                              ? -amountValue.abs()
                              : amountValue.abs();

                          // Parse the date
                          final date = DateFormat('yyyy-MM-dd')
                              .parse(dateController.text);

                          // Create a new transaction
                          final now = DateTime.now();
                          final transaction = Transaction(
                            id: '', // Will be set by Firestore
                            userId: authController.user.value!.uid,
                            description: descriptionController.text,
                            amount: amount,
                            category: selectedCategory.value!,
                            date: date,
                            createdAt: now,
                            updatedAt: now,
                          );

                          controller.addTransaction(transaction);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
