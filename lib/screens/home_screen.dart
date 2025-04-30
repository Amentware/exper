import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exper/controllers/auth_controller.dart';
import 'package:exper/controllers/profile_controller.dart';
import 'package:exper/screens/transaction_screen.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.find<ProfileController>();
  final HomeController homeController = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  // Navigate to settings tab (index 4)
                  homeController.changeTab(4);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 16,
                  child: Obx(() {
                    final userName = profileController.userName;
                    return Text(
                      userName.isNotEmpty ? userName[0] : "U",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Obx(() => homeController.selectedIndex.value == 0
                ? Container(
                    margin: EdgeInsets.only(bottom: 40.0, right: 5),
                    child: FloatingActionButton(
                      onPressed: () {
                        Get.to(() => AddTransactionScreen(),
                                transition: Transition.rightToLeft)
                            ?.then((result) {
                          if (result == true) {
                            // Refresh transaction data if needed
                            //Get.find<TransactionController>().fetchTransactions();
                          }
                        });
                      },
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container() // Return an empty container when not on dashboard
            ),
        drawer: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            color: Colors.white,
            child: _buildSidebar(context),
          ),
        ),
        body: Obx(
          () => IndexedStack(
            index: homeController.selectedIndex.value,
            children: [
              DashboardScreen(),
              TransactionScreen(),
              BudgetScreen(),
              ReportsScreen(),
              SettingsScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 70,
              padding: const EdgeInsets.only(left: 10, top: 20, bottom: 0),
              margin: const EdgeInsets.only(bottom: 20),
              child: Image.asset(
                'assets/images/icons/LOGO2.png',
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            ),
            _buildDrawerItem(context, "Dashboard", Icons.dashboard_outlined, 0),
            _buildDrawerItem(
                context, "Transactions", Icons.receipt_outlined, 1),
            _buildDrawerItem(context, "Budgets", Icons.savings_outlined, 2),
            _buildDrawerItem(context, "Reports", Icons.bar_chart_outlined, 3),
            _buildDrawerItem(context, "Settings", Icons.settings_outlined, 4),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 16,
              child: Obx(() {
                final userName = profileController.userName;
                return Text(
                  userName.isNotEmpty ? userName[0] : "U",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
            ),
            title: Obx(() => Text(
                  profileController.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                )),
            trailing: IconButton(
              icon: const Icon(
                Icons.logout,
                size: 22,
              ),
              onPressed: () => authController.logout(),
            ),
            onTap: null, // Disable the whole tile tap
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, int index) {
    return Obx(
      () {
        final isSelected = homeController.selectedIndex.value == index;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            onTap: () {
              homeController.changeTab(index);
              Navigator.pop(context);
            },
            hoverColor: Colors.transparent,
            leading: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 22,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
