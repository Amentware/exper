import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../widgets/colors.dart';

class DashboardScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Financial summary section
          _buildFinancialSummary(),

          const SizedBox(height: 24),

          // Recent transactions section
          _buildRecentTransactions(),

          const SizedBox(height: 24),

          // Category spending section
          _buildCategorySpending(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Obx(() {
      final totalIncome = transactionController.totalIncome.value;
      final totalExpense = transactionController.totalExpense.value;
      final balance = transactionController.balance.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Income',
                    '${profileController.currency}${totalIncome.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    'Expense',
                    '${profileController.currency}${totalExpense.toStringAsFixed(2)}',
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    'Balance',
                    '${profileController.currency}${balance.toStringAsFixed(2)}',
                    balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryItem(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Obx(() {
      final recentTransactions = transactionController.transactions.isEmpty
          ? []
          : transactionController.transactions.sublist(
              0,
              transactionController.transactions.length > 5
                  ? 5
                  : transactionController.transactions.length);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to transactions tab (index 1)
                    // This will be handled in the Home controller
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            recentTransactions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: recentTransactions.map((transaction) {
                      // Find category to determine transaction type
                      final categoryMatches = categoryController.categories
                          .where((category) =>
                              category.name == transaction.category);
                      final isExpense = categoryMatches.isNotEmpty
                          ? categoryMatches.first.type == 'expense'
                          : true;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            isExpense
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isExpense ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(
                          transaction.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          transaction.category,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        trailing: Text(
                          '${profileController.currency}${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isExpense ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      );
    });
  }

  Widget _buildCategorySpending() {
    return Obx(() {
      final categoryMap = <String, double>{};

      // Calculate spending by category (only for expenses)
      for (var transaction in transactionController.transactions) {
        // Find category to determine transaction type
        final categoryMatches = categoryController.categories
            .where((category) => category.name == transaction.category);

        if (categoryMatches.isNotEmpty) {
          final category = categoryMatches.first;
          if (category.type == 'expense') {
            categoryMap[category.name] =
                (categoryMap[category.name] ?? 0) + transaction.amount;
          }
        }
      }

      // Sort categories by spending (highest first)
      final sortedCategories = categoryMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Take top 5 categories
      final topCategories = sortedCategories.take(5).toList();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Expense Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            topCategories.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No expense data yet',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: topCategories
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${profileController.currency}${entry.value.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      );
    });
  }
}
