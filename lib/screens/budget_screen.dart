import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../widgets/colors.dart';
import '../screens/home_screen.dart';

class BudgetScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final BudgetController budgetController = Get.put(BudgetController());

  BudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 16.0, bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Budgets',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Set Budget button
            InkWell(
              onTap: () => _showAddBudgetDialog(context),
              child: Container(
                height: 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      'Set Budget',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Month and year selector
            _buildMonthYearSelector(context),

            const SizedBox(height: 16),

            // Budget summary cards
            _buildBudgetSummaryCards(),

            const SizedBox(height: 20),

            // Daily budget card
            _buildDailyBudgetCard(),

            const SizedBox(height: 20),

            // Category budgets
            _buildCategoryBudgets(),

            // Add extra bottom space
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector(BuildContext context) {
    return Row(
      children: [
        // Month dropdown
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: budgetController.selectedMonth.value,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: List.generate(12, (index) => index + 1).map((month) {
                      return DropdownMenuItem<int>(
                        value: month,
                        child: Text(budgetController.monthNames[month - 1]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        budgetController.setMonthYear(
                            value, budgetController.selectedYear.value);
                      }
                    },
                  ),
                )),
          ),
        ),
        const SizedBox(width: 16),

        // Year dropdown
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: budgetController.selectedYear.value,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: List.generate(
                            5, (index) => DateTime.now().year - 2 + index)
                        .map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        budgetController.setMonthYear(
                            budgetController.selectedMonth.value, value);
                      }
                    },
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSummaryCards() {
    final formatter = NumberFormat('#,##0', 'en_IN');

    return Obx(() {
      final totalBudget = budgetController.totalBudget;
      final totalSpent = budgetController.totalSpent;
      final remaining = budgetController.remainingBudget;

      return Column(
        children: [
          // Total Budget Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Budget',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${profileController.currency}${formatter.format(totalBudget)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Spent & Remaining Cards Row
          Row(
            children: [
              // Total Spent Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Spent',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${profileController.currency}${formatter.format(totalSpent)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Remaining Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remaining',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${profileController.currency}${formatter.format(remaining)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: remaining < 0 ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildDailyBudgetCard() {
    final formatter = NumberFormat('#,##0', 'en_IN');

    return Obx(() {
      final dailyBudget = budgetController.dailyBudget;
      final remainingDays = budgetController.remainingDaysInMonth;
      final selectedMonth =
          budgetController.monthNames[budgetController.selectedMonth.value - 1];

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'For the rest of $selectedMonth',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can spend',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${profileController.currency}${formatter.format(dailyBudget)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'per day for the next $remainingDays days',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryBudgets() {
    return Obx(() {
      if (budgetController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (budgetController.budgets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Category Budgets',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap Set Budget to create one',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      final categoryProgress = budgetController.getCategoryBudgetProgress();
      final formatter = NumberFormat('#,##0', 'en_IN');

      // Calculate more accurate height with extra padding
      final itemHeight = 160.0; // Slightly reduced height per item
      final totalHeight = (categoryProgress.length * itemHeight) +
          20.0; // Less extra bottom padding

      return Padding(
        padding: const EdgeInsets.only(bottom: 20), // Reduced bottom padding
        child: SizedBox(
          height: totalHeight,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: categoryProgress.length,
            itemBuilder: (context, index) {
              final item = categoryProgress[index];
              final spent = item['spent'] as double;
              final budget = item['budget'] as double;
              final progress = item['progress'] as double;
              final category = item['category'] as String;

              // Determine color based on progress
              Color progressColor;
              if (progress >= 1.0) {
                progressColor = Colors.black; // Full black for over budget
              } else if (progress >= 0.75) {
                progressColor =
                    Colors.grey.shade700; // Dark grey for approaching limit
              } else {
                progressColor =
                    Colors.grey.shade500; // Medium grey for normal progress
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category name
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Budget progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${profileController.currency}${formatter.format(spent)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${profileController.currency}${formatter.format(budget)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Progress bar
                        LinearProgressIndicator(
                          value: progress > 1.0 ? 1.0 : progress,
                          backgroundColor: Colors.grey[200],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                          borderRadius: BorderRadius.circular(5),
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8),

                        // Percentage indicator
                        Text(
                          '${(progress * 100).toInt()}% spent',
                          style: TextStyle(
                            fontSize: 14,
                            color: progressColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Edit/Delete buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(5),
                                onTap: () => _showEditBudgetDialog(
                                    context, category, budget),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: black,
                              borderRadius: BorderRadius.circular(5),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(5),
                                onTap: () => _confirmDeleteBudget(
                                    context,
                                    budgetController
                                            .getBudgetForCategory(category)
                                            ?.id ??
                                        ''),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
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
            },
          ),
        ),
      );
    });
  }

  void _showAddBudgetDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController amountController = TextEditingController();
    RxString selectedCategory = ''.obs;

    // Get expense categories
    final expenseCategories = categoryController.categories
        .where((cat) => cat.type == 'expense')
        .map((cat) => cat.name)
        .toList();

    // Check if we have expense categories
    if (expenseCategories.isEmpty) {
      // Show message and navigate to add category
      Get.snackbar(
        'No Expense Categories',
        'Please create expense categories first',
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Close snackbar
            // Navigate to Transactions tab where categories can be added
            final HomeController homeController = Get.find();
            homeController.changeTab(1);
          },
          child: const Text(
            'Go to Categories',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    // Set initial selected category
    selectedCategory.value = expenseCategories.first;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set Category Budget',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Category dropdown
                Obx(() {
                  // Check if this category already has a budget
                  if (selectedCategory.value.isNotEmpty) {
                    final existingBudget = budgetController
                        .getBudgetForCategory(selectedCategory.value);
                    if (existingBudget != null &&
                        amountController.text.isEmpty) {
                      // Pre-fill with existing budget amount
                      amountController.text = existingBudget.amount.toString();
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
                        value: selectedCategory.value,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.category_outlined,
                                color: black, size: 20),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                        ),
                        items: expenseCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategory.value = value;

                            // Check if this category already has a budget
                            final existingBudget =
                                budgetController.getBudgetForCategory(value);
                            if (existingBudget != null) {
                              // Pre-fill with existing budget amount
                              amountController.text =
                                  existingBudget.amount.toString();
                            } else {
                              // Clear the amount field for a new budget
                              amountController.clear();
                            }
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

                // Amount field
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Budget Amount',
                    fillColor: const Color(0xFFF8F8F8),
                    filled: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.account_balance_wallet_outlined,
                          color: black, size: 20),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 45, minHeight: 45),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Buttons row
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
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              final amount =
                                  double.parse(amountController.text);
                              budgetController.setBudget(
                                  selectedCategory.value, amount);
                              Get.back();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 15),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            child: const Text(
                              'Save',
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
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBudgetDialog(
      BuildContext context, String category, double currentAmount) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController amountController = TextEditingController(
      text: currentAmount.toString(),
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Budget for $category',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Budget Amount',
                    fillColor: const Color(0xFFF8F8F8),
                    filled: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.account_balance_wallet_outlined,
                          color: black, size: 20),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 45, minHeight: 45),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Buttons row
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
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              final amount =
                                  double.parse(amountController.text);
                              budgetController.setBudget(category, amount);
                              Get.back();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 15),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            child: const Text(
                              'Save',
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
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, String budgetId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete Budget',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to delete this budget?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Buttons row
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
                        onTap: () {
                          budgetController.deleteBudget(budgetId);
                          Get.back();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 15),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
          ),
        ),
      ),
    );
  }
}
