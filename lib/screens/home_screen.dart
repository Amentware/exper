import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exper/controllers/auth_controller.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final HomeController homeController = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          // title: Container(
          //   width: 120,
          //   height: 60,
          //   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          //   alignment: Alignment.centerLeft,
          //   child: Image.asset(
          //     'assets/images/icons/LOGO2.png',
          //     fit: BoxFit.contain,
          //   ),
          // ),
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
                  child: Obx(() => Text(
                        authController.userName.value.isNotEmpty
                            ? authController.userName.value[0]
                            : "U",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
              ),
            ),
          ],
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
            children: const [
              Center(child: Text("Dashboard")),
              Center(child: Text("Transaction")),
              Center(child: Text("Budgets Screen")),
              Center(child: Text("Reports Screen")),
              Center(child: Text("Settings Screen")),
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
              child: Obx(() => Text(
                    authController.userName.value.isNotEmpty
                        ? authController.userName.value[0]
                        : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ),
            title: Obx(() => Text(
                  authController.userName.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                )),
            trailing: const Icon(
              Icons.logout,
              size: 22,
            ),
            onTap: () => authController.logout(),
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
