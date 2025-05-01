import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../models/transaction.dart' as models;
import 'add_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late TransactionController transactionController;
  late CategoryController categoryController;
  late AuthController authController;
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    transactionController = Get.find<TransactionController>();
    categoryController = Get.find<CategoryController>();
    authController = Get.find<AuthController>();
    profileController = Get.find<ProfileController>();

    // Force refresh when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionController.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          const SizedBox(height: 12),
          _buildAddTransactionButton(),
          const SizedBox(height: 12),
          _buildSearchBar(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeDropdown(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDateRangePicker(),
          const SizedBox(height: 12),
          _buildTransactionTable(),
        ],
      ),
    );
  }

  Widget _buildAddTransactionButton() {
    return InkWell(
      onTap: () {
        Get.to(() => const AddTransactionScreen(),
                transition: Transition.rightToLeft)
            ?.then((result) {
          if (result == true) {
            // Fetch transactions again and rebuild the UI
            transactionController.fetchTransactions().then((_) {
              // Ensure the UI updates by forcing a rebuild
              if (mounted) {
                setState(() {});
              }
            });
          }
        });
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Transaction',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
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
      height:
          48, // Increased height for better touch targets on smaller screens
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 8.0),
            child: Icon(Icons.search, color: black, size: 20),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: transactionController.searchController,
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 14), // Increased padding for better alignment
              ),
              style: const TextStyle(
                fontSize: 16,
              ),
              onChanged: (value) {
                try {
                  transactionController.searchTransactions(value);
                  setState(
                      () {}); // Force rebuild to update clear button visibility
                } catch (e) {
                  print('Error during search input: $e');
                }
              },
            ),
          ),
          // Clear button (if text exists)
          if (transactionController.searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
              padding: const EdgeInsets.only(right: 8.0),
              constraints: const BoxConstraints(),
              onPressed: () {
                transactionController.searchController.clear();
                transactionController.searchTransactions('');
                setState(() {}); // Force rebuild
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    // Simple dropdown without GetX reactivity
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: transactionController.selectedType.value,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.arrow_drop_down, color: black),
          ),
          isExpanded: true,
          isDense: true,
          alignment: Alignment.centerLeft,
          onChanged: (String? newValue) {
            if (newValue != null) {
              transactionController.setType(newValue);
              setState(() {}); // Force rebuild
            }
          },
          items: transactionController.types
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(Icons.filter_list_outlined, size: 18, color: black),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    // Simple dropdown without GetX reactivity
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: transactionController.selectedCategory.value,
          icon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.arrow_drop_down, color: black),
          ),
          isExpanded: true,
          isDense: true,
          alignment: Alignment.centerLeft,
          onChanged: (String? newValue) {
            if (newValue != null) {
              transactionController.setCategory(newValue);
              setState(() {}); // Force rebuild
            }
          },
          items: categoryController.categoryNames
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(Icons.category_outlined, size: 18, color: black),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return InkWell(
      onTap: () async {
        try {
          final DateTimeRange? picked = await showDateRangePicker(
            context: context,
            initialDateRange: DateTimeRange(
              start: transactionController.startDate.value,
              end: transactionController.endDate.value,
            ),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                    secondaryContainer:
                        Color(0xFFE0E0E0), // For range selection
                    onSecondaryContainer:
                        Colors.black87, // Text on range selection
                  ),
                  dialogBackgroundColor: Colors.white,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black, // Button text color
                    ),
                  ),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Colors.black),
                    titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            print('Date range selected: ${picked.start} to ${picked.end}');
            // Use local filtering instead of updating Firebase
            await transactionController.filterByDateRangeLocally(
                picked.start, picked.end);
            setState(() {}); // Force rebuild
          }
        } catch (e) {
          print('Error in date range picker: $e');
          // Show error dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'There was a problem with the date picker. Please try again.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                transactionController.selectedDateRange.value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: black),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTable() {
    return Expanded(
      child: Builder(
        builder: (context) {
          // Use local variables instead of reactive .value properties
          final isLoading = transactionController.isLoading.value;
          final filteredTransactions =
              transactionController.filteredTransactions;
          final searchText = transactionController.searchController.text;

          if (isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: black,
              ),
            );
          }

          if (filteredTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchText.isNotEmpty
                        ? 'No transactions match your search'
                        : 'No transactions found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    searchText.isNotEmpty
                        ? 'Try different search terms or clear search'
                        : 'Add your first transaction or change filters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (searchText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          transactionController.searchController.clear();
                          transactionController.searchTransactions('');
                          setState(() {}); // Force rebuild
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Clear Search',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          try {
            // Group transactions by date
            final Map<String, List<models.Transaction>> groupedTransactions =
                {};
            final Map<String, double> dailyTotals = {};

            // Format date for grouping
            String getDateKey(DateTime date) {
              return DateFormat('yyyy-MM-dd').format(date);
            }

            // Group transactions by date and calculate daily totals
            for (var transaction in filteredTransactions) {
              try {
                final dateKey = getDateKey(transaction.date);

                if (!groupedTransactions.containsKey(dateKey)) {
                  groupedTransactions[dateKey] = [];
                  dailyTotals[dateKey] = 0;
                }

                groupedTransactions[dateKey]!.add(transaction);

                // Calculate daily total (negative for expense, positive for income)
                final categoryMatches = categoryController.categories.where(
                    (category) =>
                        category.name.trim().toLowerCase() ==
                        transaction.category.trim().toLowerCase());

                if (categoryMatches.isNotEmpty) {
                  final category = categoryMatches.first;
                  if (category.type == 'expense') {
                    dailyTotals[dateKey] =
                        dailyTotals[dateKey]! - transaction.amount;
                  } else {
                    dailyTotals[dateKey] =
                        dailyTotals[dateKey]! + transaction.amount;
                  }
                } else {
                  // Default as expense
                  dailyTotals[dateKey] =
                      dailyTotals[dateKey]! - transaction.amount;
                }
              } catch (e) {
                print('Error processing transaction: $e');
                continue; // Skip problematic transaction
              }
            }

            // Sort dates in descending order (newest first)
            final sortedDates = groupedTransactions.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            if (sortedDates.isEmpty) {
              return Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }
            return ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, dateIndex) {
                try {
                  final dateKey = sortedDates[dateIndex];
                  final date = DateTime.parse(dateKey);
                  final transactions = groupedTransactions[dateKey]!;
                  final dailyTotal = dailyTotals[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: dateIndex == 0 ? 0 : 12),
                      // Single container for the entire day's transactions
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            // Date header with total
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('EEEE, MMMM d').format(date),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Builder(builder: (context) {
                                    try {
                                      // Format with thousands separators
                                      final formatter =
                                          NumberFormat('#,##0', 'en_IN');
                                      final formattedTotal =
                                          formatter.format(dailyTotal.abs());

                                      return Text(
                                        dailyTotal >= 0
                                            ? '+₹$formattedTotal'
                                            : '-₹$formattedTotal',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: dailyTotal >= 0
                                              ? Colors.green[400]
                                              : Colors.red[400],
                                        ),
                                      );
                                    } catch (e) {
                                      // Fallback for safe display
                                      return Text(
                                        dailyTotal >= 0 ? '+₹0' : '-₹0',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: dailyTotal >= 0
                                              ? Colors.green[400]
                                              : Colors.red[400],
                                        ),
                                      );
                                    }
                                  }),
                                ],
                              ),
                            ),

                            // Divider between header and transactions
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade100,
                            ),

                            // Transaction items for this date
                            ...transactions.map((transaction) {
                              try {
                                final isLastItem =
                                    transactions.last.id == transaction.id;
                                return _buildTransactionItemInGroup(
                                    transaction, isLastItem);
                              } catch (e) {
                                print('Error building transaction item: $e');
                                return Container(); // Return empty container if there's an error
                              }
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  );
                } catch (e) {
                  print('Error building date group: $e');
                  return Container(); // Return empty container for problematic date groups
                }
              },
            );
          } catch (e) {
            print('Error building transaction list: $e');
            return Center(
              child: Text(
                'Error displaying transactions',
                style: TextStyle(color: Colors.red[400]),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTransactionItemInGroup(
      models.Transaction transaction, bool isLastItem) {
    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(0),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog();
      },
      onDismissed: (direction) async {
        // First remove the transaction from the local list
        final index = transactionController.filteredTransactions
            .indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          // Remove from local list immediately to prevent the dismissed widget error
          transactionController.filteredTransactions.removeAt(index);
        }

        // Then delete from the database
        await transactionController.deleteTransaction(transaction.id);

        // Force rebuild
        if (mounted) {
          setState(() {});
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Category Icon
                _buildCategoryIcon(),
                const SizedBox(width: 12),
                // Description
                _buildTransactionDescription(transaction),
                // Amount
                _buildTransactionAmount(transaction),
              ],
            ),
          ),
          // Add divider only if this isn't the last item
          if (!isLastItem)
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade100,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Delete Transaction",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this transaction?",
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          actions: [
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: black,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
      },
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.restaurant,
        color: Colors.grey,
        size: 20,
      ),
    );
  }

  Widget _buildTransactionDescription(models.Transaction transaction) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            transaction.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionAmount(models.Transaction transaction) {
    final categoryMatches = categoryController.categories.where((category) =>
        category.name.trim().toLowerCase() ==
        transaction.category.trim().toLowerCase());

    final isExpense = categoryMatches.isNotEmpty
        ? categoryMatches.first.type == 'expense'
        : true;

    return Text(
      isExpense
          ? '-₹${transaction.formattedAmount}'
          : '+₹${transaction.formattedAmount}',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isExpense ? Colors.red[400] : Colors.green[400],
      ),
    );
  }

  // Original method kept for standalone items if needed
  Widget _buildStandaloneTransactionItem(models.Transaction transaction) {
    return Dismissible(
      key: Key(transaction.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog();
      },
      onDismissed: (direction) async {
        // First remove the transaction from the local list
        final index = transactionController.filteredTransactions
            .indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          // Remove from local list immediately to prevent the dismissed widget error
          transactionController.filteredTransactions.removeAt(index);
        }

        // Then delete from the database
        await transactionController.deleteTransaction(transaction.id);

        // Force rebuild
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    transaction.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Amount - Using non-reactive approach
            Builder(builder: (context) {
              final categoryMatches = categoryController.categories.where(
                  (category) =>
                      category.name.trim().toLowerCase() ==
                      transaction.category.trim().toLowerCase());

              final isExpense = categoryMatches.isNotEmpty
                  ? categoryMatches.first.type == 'expense'
                  : true;

              return Text(
                isExpense
                    ? '-₹${transaction.formattedAmount}'
                    : '+₹${transaction.formattedAmount}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isExpense ? Colors.red[400] : Colors.green[400],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
