import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../models/transaction.dart';
import '../widgets/colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final authController = Get.find<AuthController>();
  final profileController = Get.find<ProfileController>();
  final transactionController = Get.find<TransactionController>();
  final categoryController = Get.find<CategoryController>();

  final RxBool isExpense = true.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Initialize selected category from the list if available
    if (categoryController.categoryNames.isNotEmpty) {
      // Skip "All Categories" entry which is at index 0
      if (categoryController.categoryNames.length > 1) {
        selectedCategory.value = categoryController.categoryNames[1];
      }
    } else {
      // Fetch categories if not loaded yet
      categoryController.fetchCategories().then((_) {
        if (categoryController.categoryNames.length > 1) {
          selectedCategory.value = categoryController.categoryNames[1];
        }
      });
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> saveTransaction() async {
    if (!formKey.currentState!.validate() || selectedCategory.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    isLoading.value = true;

    try {
      final userId = authController.user.value!.uid;
      final amount = double.parse(amountController.text);
      // No need to apply sign based on transaction type
      final date = DateFormat('yyyy-MM-dd').parse(dateController.text);
      final now = DateTime.now();

      // Use category as description if no description is provided
      String description = descriptionController.text.trim();
      if (description.isEmpty) {
        description = selectedCategory.value;
      }

      print(
          'CREATING TRANSACTION: userId=$userId, description=$description, amount=$amount, category=${selectedCategory.value}, date=$date');

      final transaction = Transaction(
        id: '', // Will be set by Firestore
        userId: userId,
        description: description,
        amount: amount, // Use amount directly without applying sign
        category: selectedCategory.value,
        date: date,
        createdAt: now,
        updatedAt: now,
      );

      // Print the exact data being saved to Firestore
      print('TRANSACTION DATA BEING SAVED: ${transaction.toMap()}');

      await transactionController.addTransaction(transaction);

      Get.back(result: true); // Success

      // Format the amount with currency symbol
      final formattedAmount =
          profileController.currency + amountController.text;
      final transactionType = isExpense.value ? 'Expense' : 'Income';

      Get.snackbar(
        'Transaction Added',
        '$transactionType of $formattedAmount added to ${selectedCategory.value}',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      print('Error saving transaction: $e');
      print('Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Failed to save transaction',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
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
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (isLoading.value && categoryController.categoryNames.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              color: black,
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transaction type selector
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Obx(() => Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => isExpense.value = true,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    color: isExpense.value
                                        ? black
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Expense',
                                    style: TextStyle(
                                      color: isExpense.value
                                          ? Colors.white
                                          : black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => isExpense.value = false,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    color: !isExpense.value
                                        ? black
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Income',
                                    style: TextStyle(
                                      color: !isExpense.value
                                          ? Colors.white
                                          : black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),

                  const SizedBox(height: 24),

                  // Amount field
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      fillColor: const Color(0xFFF8F8F8),
                      filled: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.account_balance_wallet_outlined,
                            color: black, size: 20),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 45, minHeight: 45),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      fillColor: const Color(0xFFF8F8F8),
                      filled: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.description_outlined,
                            color: black, size: 20),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 45, minHeight: 45),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category dropdown
                  Obx(() {
                    // Filter categories based on transaction type (expense/income)
                    final String typeFilter =
                        isExpense.value ? 'expense' : 'income';

                    // Get categories of the selected type from the controller
                    final filteredCategories = categoryController.categories
                        .where((category) => category.type == typeFilter)
                        .map((category) => category.name)
                        .toList();

                    if (filteredCategories.isEmpty) {
                      return Text(
                        'No ${typeFilter} categories available. Please add categories first.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    // Update selected category when switching between expense/income
                    if (selectedCategory.value.isEmpty ||
                        !filteredCategories.contains(selectedCategory.value)) {
                      if (filteredCategories.isNotEmpty) {
                        selectedCategory.value = filteredCategories.first;
                      }
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: DropdownButtonFormField<String>(
                          value: filteredCategories
                                  .contains(selectedCategory.value)
                              ? selectedCategory.value
                              : (filteredCategories.isNotEmpty
                                  ? filteredCategories.first
                                  : null),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.category_outlined,
                                  color: black, size: 20),
                            ),
                            prefixIconConstraints:
                                BoxConstraints(minWidth: 45, minHeight: 45),
                            contentPadding: EdgeInsets.only(
                                top: 16, bottom: 16, left: 0, right: 12),
                            fillColor: const Color(0xFFF8F8F8),
                            filled: true,
                          ),
                          dropdownColor: Colors.white,
                          isExpanded: true,
                          itemHeight: 50,
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_drop_down, color: black),
                          ),
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          selectedItemBuilder: (BuildContext context) {
                            return filteredCategories
                                .map<Widget>((String item) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                          hint: Text(
                            'Select Category',
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          menuMaxHeight: 300,
                          borderRadius: BorderRadius.circular(5),
                          items: filteredCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              selectedCategory.value = value;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Date picker
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                child: Icon(Icons.calendar_today,
                                    color: black, size: 20),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                dateController.text,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit buttons - using same layout as forget password screen
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () => Get.back(),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(15),
                              decoration: const ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Material(
                          color: black,
                          borderRadius: BorderRadius.circular(5),
                          child: InkWell(
                            splashColor: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                            onTap: isLoading.value ? null : saveTransaction,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(15),
                              decoration: const ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                              child: Obx(() {
                                if (isLoading.value) {
                                  return const SizedBox(
                                    height: 16.0,
                                    width: 16.0,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 4,
                                    ),
                                  );
                                } else {
                                  return const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  );
                                }
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
