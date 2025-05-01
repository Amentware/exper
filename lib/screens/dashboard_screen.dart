import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/budget_controller.dart';
import '../widgets/colors.dart';
import '../screens/home_screen.dart';

class DashboardScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final BudgetController budgetController = Get.put(BudgetController());

  DashboardScreen({Key? key}) : super(key: key);

  // Helper method to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // Ensure data is loaded when the dashboard is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if date range needs to be updated
      _checkAndUpdateDateRange();

      // Force refresh categories and transactions when dashboard is shown
      categoryController.fetchCategories().then((_) {
        transactionController.fetchTransactions();
      });
    });

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Date range selector
            _buildDateRangeSelector(context),

            const SizedBox(height: 20),

            // Financial summary cards
            _buildFinancialSummaryCards(),

            const SizedBox(height: 24),

            // Expense chart section (pie chart)
            _buildExpenseChart(),

            const SizedBox(height: 24),

            // Daily trend chart section
            _buildDailyTrendChart(),

            const SizedBox(height: 24),

            // Recent transactions section
            _buildRecentTransactions(),

            const SizedBox(height: 24),

            // Top Budget Categories Section
            _buildTopBudgetCategories(),

            const SizedBox(height: 24),

            // Category spending section
            _buildCategorySpending(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Obx(() {
      final startDate = profileController.startDate;
      final endDate = profileController.endDate;
      final dateFormat = DateFormat('MMM dd, yyyy');

      return GestureDetector(
        onTap: () => _showDateRangePicker(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 20, color: Colors.black87),
                  const SizedBox(width: 12),
                  Text(
                    '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black54),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: profileController.startDate,
      end: profileController.endDate,
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              secondaryContainer: Color(0xFFE0E0E0), // For range selection
              onSecondaryContainer: Colors.black87, // Text on range selection
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
                  fontWeight: FontWeight.bold),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      // Update Firebase profile with the new date range
      await profileController.setDateRange(
        pickedDateRange.start,
        pickedDateRange.end,
      );

      // Reload transactions for the new date range
      await transactionController.fetchTransactions();
    }
  }

  Widget _buildFinancialSummaryCards() {
    return Obx(() {
      final formatter = NumberFormat('#,##0', 'en_IN');
      final totalIncome = transactionController.totalIncome.value;
      final totalExpense = transactionController.totalExpense.value;
      final balance = transactionController.balance.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  balance < 0
                      ? '-${profileController.currency}${formatter.format(balance.abs())}'
                      : '${profileController.currency}${formatter.format(balance)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: balance < 0 ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Income & Expense Cards Row
          Row(
            children: [
              // Income Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward_outlined,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${profileController.currency}${formatter.format(totalIncome)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Expense Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward_outlined,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Expense',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${profileController.currency}${formatter.format(totalExpense)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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

  Widget _buildExpenseChart() {
    return Obx(() {
      final categoryMap = <String, double>{};
      final categoryColorMap = <String, Color>{};
      final expenseColors = [
        Colors.black,
        Colors.grey.shade700,
        Colors.grey.shade500,
        Colors.grey.shade400,
        Colors.grey.shade300,
        Colors.grey.shade600,
        Colors.grey.shade800,
        Colors.grey.shade900,
      ];

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

      // Take top 5 categories for the chart
      final topCategories = sortedCategories.take(5).toList();

      // Assign colors to categories
      for (int i = 0; i < topCategories.length; i++) {
        categoryColorMap[topCategories[i].key] =
            expenseColors[i % expenseColors.length];
      }

      // Calculate total for percentages
      final totalExpense =
          topCategories.fold(0.0, (sum, item) => sum + item.value);

      // Create pie chart sections
      final sections = topCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final percentage =
            totalExpense > 0 ? (data.value / totalExpense * 100) : 0;

        return PieChartSectionData(
          color: categoryColorMap[data.key],
          value: data.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50.0,
          titleStyle: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();

      return Container(
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
              'Expense Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
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
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 40,
                                sectionsSpace: 0,
                                startDegreeOffset: 180,
                              ),
                              swapAnimationDuration:
                                  const Duration(milliseconds: 400),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Builder(builder: (context) {
                                    final formatter =
                                        NumberFormat('#,##0', 'en_IN');
                                    return Text(
                                      '${profileController.currency}${formatter.format(totalExpense)}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chart legend
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: topCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final formatter = NumberFormat('#,##0', 'en_IN');
                          final percentage = totalExpense > 0
                              ? (category.value / totalExpense * 100)
                              : 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 6),
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: categoryColorMap[category.key],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${category.key} (${percentage.toStringAsFixed(0)}%)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${profileController.currency}${formatter.format(category.value)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ],
        ),
      );
    });
  }

  Widget _buildDailyTrendChart() {
    return Container(
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
            'Daily Spending Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Obx(() => _buildSpendingTrendChartContent()),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendChartContent() {
    try {
      print('Total transactions: ${transactionController.transactions.length}');
      if (transactionController.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, color: Colors.grey[400], size: 40),
              const SizedBox(height: 8),
              const Text(
                'No expense data available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Text(
                'Try selecting a different date range',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }

      final DateFormat dateKeyFormat = DateFormat('yyyy-MM-dd');

      // Debug info
      print('---- CHART DEBUG INFO ----');
      print('Transaction count: ${transactionController.transactions.length}');

      // Get the actual end date from the profile controller (capped at today)
      final DateTime today = DateTime.now();
      final DateTime profileEndDate = profileController.endDate;
      // Use the earlier of today or profile end date
      final DateTime endDate =
          profileEndDate.isAfter(today) ? today : profileEndDate;

      // Calculate start date as 6 days before end date
      final DateTime startDate = endDate.subtract(const Duration(days: 6));

      // Format dates for comparison
      final String startDateStr = dateKeyFormat.format(startDate);
      final String endDateStr = dateKeyFormat.format(endDate);

      print('Chart date range: $startDateStr to $endDateStr');

      // Create a set to track days we've already seen
      final Set<int> seenDays = {};
      List<DateTime> chartDays = [];

      // Generate dates from start to end date
      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate) || isSameDay(currentDate, endDate)) {
        // Only add the day if we haven't seen this day number before
        if (!seenDays.contains(currentDate.day)) {
          chartDays.add(
              DateTime(currentDate.year, currentDate.month, currentDate.day));
          seenDays.add(currentDate.day);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // If we need exactly 7 points but have fewer, space them out evenly
      if (chartDays.length < 7) {
        final int daysBetween = endDate.difference(startDate).inDays;
        if (daysBetween >= 6) {
          // Create evenly spaced days
          chartDays = [];
          for (int i = 0; i <= 6; i++) {
            final step = daysBetween / 6;
            final daysToAdd = (i * step).round();
            chartDays.add(DateTime(
              startDate.year,
              startDate.month,
              startDate.day + daysToAdd,
            ));
          }
        }
      }

      // Limit to 7 days if we have more
      if (chartDays.length > 7) {
        chartDays = chartDays.take(7).toList();
      }

      // Debug chart days
      print('Using ${chartDays.length} unique days for chart:');
      chartDays.forEach((day) =>
          print('Chart day: ${dateKeyFormat.format(day)} (${day.day})'));

      // Initialize all days with zero amount
      final Map<String, double> dailySpending = {};
      for (var day in chartDays) {
        final dateKey = dateKeyFormat.format(day);
        dailySpending[dateKey] = 0.0;
        print('Added day to chart: $dateKey');
      }

      // Print transactions for debugging
      transactionController.transactions.forEach((transaction) => print(
          'Transaction: ${transaction.date} - ${transaction.amount} - ${transaction.category}'));

      // Use all transactions and filter for our 7-day window and category if applicable
      for (var transaction in transactionController.transactions) {
        try {
          final transactionDate = transaction.date;
          final dateKey = dateKeyFormat.format(transactionDate);

          // Check if transaction is within our 7-day window
          if (transactionDate
                  .isAfter(startDate.subtract(const Duration(days: 1))) &&
              transactionDate.isBefore(endDate.add(const Duration(days: 1)))) {
            print('Processing transaction in date range: $dateKey');

            // Only process if this is one of our chart days
            if (dailySpending.containsKey(dateKey)) {
              // Only count expenses (not income)
              bool isExpense = true;

              // Find category to determine expense type
              final categoryMatches = categoryController.categories
                  .where((category) => category.name == transaction.category);

              if (categoryMatches.isNotEmpty) {
                final category = categoryMatches.first;
                isExpense = category.type == 'expense';

                // Only add to chart if it's an expense
                if (isExpense) {
                  // Always add transaction amount (assuming it's positive)
                  double previousAmount = dailySpending[dateKey] ?? 0.0;
                  double newAmount = previousAmount + transaction.amount;
                  dailySpending[dateKey] = newAmount;
                  print(
                      'Added expense: $dateKey - Previous: $previousAmount, Added: ${transaction.amount}, New: $newAmount');
                }
              }
            }
          }
        } catch (e) {
          print('Error processing transaction: $e');
        }
      }

      // Print final data
      dailySpending
          .forEach((key, value) => print('Final spending: $key = $value'));

      // Prepare data for line chart
      final List<FlSpot> spots = [];
      int index = 0;
      double maxY = 0.0;

      for (var day in chartDays) {
        final dateKey = dateKeyFormat.format(day);
        final amount = dailySpending[dateKey] ?? 0.0;

        // Always add the spot regardless of amount to maintain chart continuity
        spots.add(FlSpot(index.toDouble(), amount));
        print('Adding spot: x=$index, y=$amount');

        // Find maximum value for scaling
        if (amount > maxY) {
          maxY = amount;
        }

        index++;
      }
      print('Chart spots: $spots');
      print('Max Y value: $maxY');

      // Ensure we have a minimum value to display
      maxY = maxY <= 0 ? 100 : maxY * 1.2;

      // Format for display - use simpler date format for x-axis
      final dayFormat = DateFormat('d'); // Just the day number
      final monthDayFormat = DateFormat('MMM d'); // For tooltip

      // If no actual spending data, show empty chart
      if (spots.every((spot) => spot.y == 0)) {
        return _buildEmptyChart();
      }

      return LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval:
                    1, // Only show labels at integer values (actual data points)
                getTitlesWidget: (value, meta) {
                  // Only show labels for exact data points (whole numbers)
                  if (value.toInt() == value &&
                      value.toInt() >= 0 &&
                      value.toInt() < chartDays.length) {
                    final day = chartDays[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dayFormat.format(day),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 5,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  final formatter = NumberFormat('#,##0', 'en_IN');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value >= 1000
                          ? '${(value / 1000).toStringAsFixed(1)}k'
                          : formatter.format(value),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              color: Colors.black, // Change to black
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: Colors.black, // Change to black
                  strokeColor: Colors.white,
                  strokeWidth: 1,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.grey.shade200.withOpacity(0.5), // Light grey
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final amount = barSpot.y;
                  final date = chartDays[barSpot.x.toInt()];
                  final formatter = NumberFormat('#,##0', 'en_IN');
                  return LineTooltipItem(
                    '${monthDayFormat.format(date)}\n-${profileController.currency}${formatter.format(amount)}',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  );
                }).toList();
              },
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error in chart: $e');
      return _buildEmptyChart();
    }
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, color: Colors.grey[400], size: 40),
          const SizedBox(height: 8),
          const Text(
            'No daily spending data',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const Text(
            'Try selecting a different date range',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Obx(() {
      final formatter = NumberFormat('#,##0', 'en_IN');

      // Sort transactions by date (most recent first)
      final sortedTransactions = [...transactionController.transactions];
      sortedTransactions.sort((a, b) => b.date.compareTo(a.date));

      final recentTransactions = sortedTransactions.isEmpty
          ? []
          : sortedTransactions.sublist(
              0, sortedTransactions.length > 5 ? 5 : sortedTransactions.length);

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
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
                    Get.find<HomeController>().changeTab(1);
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
            const SizedBox(height: 12),
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

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            // Transaction icon
                            Container(
                              alignment: Alignment.center,
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  isExpense
                                      ? Icons.arrow_downward_outlined
                                      : Icons.arrow_upward_outlined,
                                  color: isExpense ? Colors.red : Colors.green,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Transaction details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    transaction.category,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      height: 1.2,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Transaction amount
                            Container(
                              alignment: Alignment.centerRight,
                              child: Text(
                                // Add + or - prefix based on transaction type and color code
                                isExpense
                                    ? '-${profileController.currency}${formatter.format(transaction.amount)}'
                                    : '+${profileController.currency}${formatter.format(transaction.amount)}',
                                style: TextStyle(
                                  // Use red for expense and green for income amounts
                                  color: isExpense
                                      ? Colors.red.shade400
                                      : Colors.green.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
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
      final formatter = NumberFormat('#,##0', 'en_IN');
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Category icon
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.category,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Category name and amount with better alignment
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          entry.key,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          '${profileController.currency}${formatter.format(entry.value)}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
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

  // Build top budget categories section
  Widget _buildTopBudgetCategories() {
    return Obx(() {
      // Get budgets even if empty for display
      final formatter = NumberFormat('#,##0', 'en_IN');
      final topBudgets = budgetController.getTopBudgetCategories(limit: 3);

      // Container always shown, but with different content based on budget status
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to budget tab (index 2)
                    Get.find<HomeController>().changeTab(2);
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show empty state message if no budgets
            topBudgets.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No budget set yet',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: topBudgets.map((budget) {
                      final category = budget['category'] as String;
                      final spent = budget['spent'] as double;
                      final total = budget['budget'] as double;
                      final progress = budget['progress'] as double;

                      // Determine color based on progress
                      Color progressColor;
                      if (progress >= 1.0) {
                        progressColor =
                            Colors.black; // Full black for over budget
                      } else if (progress >= 0.75) {
                        progressColor = Colors
                            .grey.shade700; // Dark grey for approaching limit
                      } else {
                        progressColor = Colors
                            .grey.shade500; // Medium grey for normal progress
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${profileController.currency}${formatter.format(spent)} / ${profileController.currency}${formatter.format(total)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: progressColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress > 1.0 ? 1.0 : progress,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(progressColor),
                              borderRadius: BorderRadius.circular(5),
                              minHeight: 6,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      );
    });
  }

  // Check if the current date is past the end date and update if needed
  void _checkAndUpdateDateRange() {
    final DateTime now = DateTime.now();

    // Check if current date is past the end date
    if (now.isAfter(profileController.endDate)) {
      print(
          'Current date is past the selected end date, updating to current month...');

      // Get the first day of the current month
      final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);

      // Get the last day of the current month
      final DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      // Update the date range
      profileController.setDateRange(firstDayOfMonth, lastDayOfMonth).then((_) {
        // Fetch transactions with the new date range
        transactionController.fetchTransactions();
      });
    }
  }
}
