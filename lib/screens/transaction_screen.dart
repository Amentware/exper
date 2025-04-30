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

class TransactionScreen extends StatelessWidget {
  final transactionController = Get.put(TransactionController());
  final categoryController = Get.put(CategoryController());
  final authController = Get.find<AuthController>();
  final profileController = Get.find<ProfileController>();

  TransactionScreen({Key? key}) : super(key: key);

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
    );
  }

  Widget _buildAddTransactionButton() {
    return InkWell(
      onTap: () {
        Get.to(() => AddTransactionScreen(), transition: Transition.rightToLeft)
            ?.then((result) {
          if (result == true) {
            // Refresh data after adding a transaction
            transactionController.fetchTransactions();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(5),
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
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: transactionController.searchController,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: Icon(Icons.search, color: black),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          transactionController.searchTransactions(value);
        },
      ),
    );
  }

  Widget _buildFilterDropdown(String title) {
    if (title == 'All Types') {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
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
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return transactionController.types
                            .map<Widget>((String item) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(Icons.filter_list_outlined,
                                    size: 18, color: black),
                                SizedBox(width: 12),
                                Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          transactionController.setType(newValue);
                        }
                      },
                      items: transactionController.types
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.grey.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: transactionController.selectedCategory.value,
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.arrow_drop_down, color: black),
                        ),
                        isExpanded: true,
                        isDense: true,
                        alignment: Alignment.centerLeft,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return categoryController.categoryNames
                              .map<Widget>((String item) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(Icons.category_outlined,
                                      size: 18, color: black),
                                  SizedBox(width: 12),
                                  Text(
                                    item,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            transactionController.setCategory(newValue);
                          }
                        },
                        items: categoryController.categoryNames
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDateRangePicker() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.grey.withOpacity(0.1),
        onTap: () async {
          final DateTimeRange? picked = await showDateRangePicker(
            context: Get.context!,
            initialDateRange: DateTimeRange(
              start: transactionController.startDate.value,
              end: transactionController.endDate.value,
            ),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: black,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: black,
                  ),
                  dialogBackgroundColor: Colors.white,
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: black,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            transactionController.setDateRange(picked.start, picked.end);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: black),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Text(
                      transactionController.selectedDateRange.value,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
              ),
              Icon(Icons.arrow_drop_down, color: black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTable() {
    return Expanded(
      child: Obx(() {
        if (transactionController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: black,
            ),
          );
        }

        if (transactionController.filteredTransactions.isEmpty) {
          print('TRANSACTION SCREEN: No transactions to display');
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
                  'No transactions found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first transaction or change filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        print(
            'TRANSACTION SCREEN: Displaying ${transactionController.filteredTransactions.length} transactions');
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
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
                  itemCount: transactionController.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction =
                        transactionController.filteredTransactions[index];
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
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: Colors.white,
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Material(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          onTap: () =>
                                              Navigator.of(context).pop(false),
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(15),
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5)),
                                                side: BorderSide(
                                                    color: Colors.grey[300]!),
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
                                        borderRadius: BorderRadius.circular(5),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          onTap: () =>
                                              Navigator.of(context).pop(true),
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(15),
                                            decoration: const ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
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
                              actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        transactionController.deleteTransaction(transaction.id);
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Obx(() {
                                  final categoryMatches = categoryController
                                      .categories
                                      .where((category) =>
                                          category.name ==
                                          transaction.category);

                                  final isExpense = categoryMatches.isNotEmpty
                                      ? categoryMatches.first.type == 'expense'
                                      : true;

                                  return Text(
                                    '₹${transaction.amount}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          isExpense ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  );
                                }),
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
}
