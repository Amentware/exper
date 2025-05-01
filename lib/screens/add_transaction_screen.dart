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
  final timeController = TextEditingController();
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
    timeController.text = DateFormat('h:mm a').format(DateTime.now());

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
    timeController.dispose();
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

      // Parse date and time separately and combine them
      final dateOnly = DateFormat('yyyy-MM-dd').parse(dateController.text);
      final timeOnly = DateFormat('h:mm a').parse(timeController.text);

      // Combine date and time
      final date = DateTime(
        dateOnly.year,
        dateOnly.month,
        dateOnly.day,
        timeOnly.hour,
        timeOnly.minute,
      );

      final now = DateTime.now();

      // Use category as description if no description is provided
      String description = descriptionController.text.trim();
      if (description.isEmpty) {
        description = selectedCategory.value;
      }

      // Get the category ID for the selected category name
      final categoryObj =
          categoryController.getCategoryByName(selectedCategory.value);
      if (categoryObj == null) {
        throw Exception('Category not found: ${selectedCategory.value}');
      }

      final categoryId = categoryObj.id;

      print(
          'CREATING TRANSACTION: userId=$userId, description=$description, amount=$amount, categoryId=$categoryId, date=$date');

      final transaction = Transaction(
        id: '', // Will be set by Firestore
        userId: userId,
        description: description,
        amount: amount,
        categoryId: categoryId,
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
    // Get current date from the date controller
    final DateTime initialDate = dateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(dateController.text)
        : DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // Ensure dragging is enabled
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // 50% of screen initially
          minChildSize: 0.3, // Minimum size when collapsed
          maxChildSize: 0.8, // Maximum size when expanded
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle for the bottom sheet
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Calendar widget
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListView(
                        controller:
                            scrollController, // Use the provided controller
                        children: [
                          CalendarDatePicker(
                            initialDate: initialDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                            onDateChanged: (DateTime date) {
                              // Update the date controller
                              dateController.text =
                                  DateFormat('yyyy-MM-dd').format(date);
                              // Close the modal
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    setState(() {
      // Update UI displayed format to show day name after selection
      if (dateController.text.isNotEmpty) {
        final date = DateFormat('yyyy-MM-dd').parse(dateController.text);
        final displayDate = DateFormat('EEE, MMM d').format(date);
        // No need to update dateController.text here as it's already been updated in onDateChanged
      }
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    // Parse existing time or default to current time
    final TimeOfDay initialTime = timeController.text.isNotEmpty
        ? TimeOfDay.fromDateTime(
            DateFormat('h:mm a').parse(timeController.text))
        : TimeOfDay.now();

    TimeOfDay selectedTime = initialTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // Ensure dragging is enabled
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // 70% of screen initially
          minChildSize: 0.3, // Minimum size when collapsed
          maxChildSize: 0.8, // Maximum size when expanded
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle for the bottom sheet
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time picker
                  Expanded(
                    child: ListView(
                      controller:
                          scrollController, // Use the provided controller
                      children: [
                        StatefulBuilder(builder: (context, setModalState) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Time display
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  selectedTime.format(context),
                                  style: TextStyle(
                                    fontSize: 36.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              // Hour picker
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTimeColumn(
                                    context: context,
                                    values: List.generate(
                                        12, (i) => i == 0 ? 12 : i),
                                    selectedValue: selectedTime.hourOfPeriod,
                                    label: 'Hour',
                                    onChanged: (value) {
                                      setModalState(() {
                                        final isPM =
                                            selectedTime.period == DayPeriod.pm;
                                        final hour = isPM
                                            ? (value == 12 ? 12 : value + 12)
                                            : (value == 12 ? 0 : value);
                                        selectedTime = TimeOfDay(
                                            hour: hour,
                                            minute: selectedTime.minute);
                                      });
                                    },
                                  ),

                                  SizedBox(width: 20),

                                  // Minute picker
                                  _buildTimeColumn(
                                    context: context,
                                    values: List.generate(60, (i) => i),
                                    selectedValue: selectedTime.minute,
                                    label: 'Minute',
                                    onChanged: (value) {
                                      setModalState(() {
                                        selectedTime = TimeOfDay(
                                            hour: selectedTime.hour,
                                            minute: value);
                                      });
                                    },
                                  ),

                                  SizedBox(width: 20),

                                  // AM/PM picker
                                  Column(
                                    children: [
                                      Text(
                                        'AM/PM',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setModalState(() {
                                                  if (selectedTime.period ==
                                                      DayPeriod.pm) {
                                                    // Convert to AM
                                                    final hour = selectedTime
                                                                .hour >=
                                                            12
                                                        ? selectedTime.hour - 12
                                                        : selectedTime.hour;
                                                    selectedTime = TimeOfDay(
                                                        hour: hour,
                                                        minute: selectedTime
                                                            .minute);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 80,
                                                height: 44,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: selectedTime.period ==
                                                          DayPeriod.am
                                                      ? black
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                  ),
                                                ),
                                                child: Text(
                                                  'AM',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        selectedTime.period ==
                                                                DayPeriod.am
                                                            ? Colors.white
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey.shade300),
                                            InkWell(
                                              onTap: () {
                                                setModalState(() {
                                                  if (selectedTime.period ==
                                                      DayPeriod.am) {
                                                    // Convert to PM
                                                    final hour =
                                                        selectedTime.hour + 12;
                                                    selectedTime = TimeOfDay(
                                                        hour: hour >= 24
                                                            ? hour - 12
                                                            : hour,
                                                        minute: selectedTime
                                                            .minute);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 80,
                                                height: 44,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: selectedTime.period ==
                                                          DayPeriod.pm
                                                      ? black
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                ),
                                                child: Text(
                                                  'PM',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        selectedTime.period ==
                                                                DayPeriod.pm
                                                            ? Colors.white
                                                            : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Confirm button
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24.0, horizontal: 16.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    timeController.text =
                                        selectedTime.format(context);
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: black,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    setState(() {});
  }

  Future<void> _showCategoryDialog(
      BuildContext context, String typeFilter) async {
    // Get categories of the selected type from the controller
    final filteredCategories = categoryController.categories
        .where((category) => category.type == typeFilter)
        .toList();

    if (filteredCategories.isEmpty) {
      Get.snackbar(
        'Error',
        'No ${typeFilter} categories available. Please add categories first.',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    // Update selected category when switching between expense/income
    if (selectedCategory.value.isEmpty ||
        !filteredCategories
            .map((c) => c.name)
            .contains(selectedCategory.value)) {
      if (filteredCategories.isNotEmpty) {
        selectedCategory.value = filteredCategories.first.name;
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true, // Ensure dragging is enabled
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // 50% of screen initially
          minChildSize: 0.3, // Minimum size when collapsed
          maxChildSize: 0.8, // Maximum size when expanded
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle for the bottom sheet
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select ${typeFilter[0].toUpperCase() + typeFilter.substring(1)} Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Categories grid
                  Expanded(
                    child: GridView.count(
                      controller:
                          scrollController, // Use the provided controller
                      padding: const EdgeInsets.all(12),
                      crossAxisCount: 4,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                      children: filteredCategories.map((category) {
                        return InkWell(
                          onTap: () {
                            selectedCategory.value = category.name;
                            Get.back();
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(
                                    categoryController
                                        .getCategoryIcon(category.id),
                                    size: 28,
                                    color: black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 60,
                                child: Text(
                                  category.name.length > 10
                                      ? category.name.substring(0, 9) + '..'
                                      : category.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to build time columns (hours, minutes)
  Widget _buildTimeColumn({
    required BuildContext context,
    required List<int> values,
    required int selectedValue,
    required String label,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 180,
          width: 70,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: values.length,
            itemExtent: 50,
            itemBuilder: (context, index) {
              final value = values[index];
              final isSelected = value == selectedValue;
              final formattedValue = value.toString().padLeft(2, '0');

              return InkWell(
                onTap: () => onChanged(value),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? black : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    formattedValue,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
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
                                    borderRadius: BorderRadius.circular(10),
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
                                    borderRadius: BorderRadius.circular(10),
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
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.account_balance_wallet_outlined,
                            color: black, size: 20),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 45, minHeight: 45),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
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
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.description_outlined,
                            color: black, size: 20),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 45, minHeight: 45),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category selection field (now a button that opens a dialog)
                  Obx(() {
                    // Filter categories based on transaction type (expense/income)
                    final String typeFilter =
                        isExpense.value ? 'expense' : 'income';

                    // Get categories of the selected type from the controller
                    final filteredCategories = categoryController.categories
                        .where((category) => category.type == typeFilter)
                        .toList();

                    if (filteredCategories.isEmpty) {
                      return Text(
                        'No ${typeFilter} categories available. Please add categories first.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    // Update selected category when switching between expense/income
                    if (selectedCategory.value.isEmpty ||
                        !filteredCategories
                            .map((c) => c.name)
                            .contains(selectedCategory.value)) {
                      if (filteredCategories.isNotEmpty) {
                        selectedCategory.value = filteredCategories.first.name;
                      }
                    }

                    // Get the category object for the currently selected category
                    final selectedCategoryObj = categoryController
                        .getCategoryByName(selectedCategory.value);

                    return InkWell(
                      onTap: () => _showCategoryDialog(context, typeFilter),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                selectedCategoryObj != null
                                    ? categoryController
                                        .getCategoryIcon(selectedCategoryObj.id)
                                    : Icons.category_outlined,
                                color: black,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                selectedCategory.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(Icons.arrow_drop_down, color: black),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Date picker section
                  Row(
                    children: [
                      // Date picker
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _selectDate(context),
                              child: Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Icon(Icons.calendar_today,
                                          color: black, size: 22),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        DateFormat('EEE, MMM d').format(
                                            DateFormat('yyyy-MM-dd')
                                                .parse(dateController.text)),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12),

                      // Time picker
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _selectTime(context),
                              child: Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Icon(Icons.access_time,
                                          color: black, size: 22),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      timeController.text,
                                      style: const TextStyle(
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit buttons - using same layout as forget password screen
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => Get.back(),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(15),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Material(
                          color: black,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            splashColor: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            onTap: isLoading.value ? null : saveTransaction,
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(15),
                              decoration: const ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
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
