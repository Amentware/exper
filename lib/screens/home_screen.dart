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
          title: Obx(() => Text("Hello, ${authController.userName.value}")),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authController.logout();
              },
            ),
          ],
        ),
        drawer: Drawer(
  backgroundColor: Colors.white,
  child: Container(
    decoration: BoxDecoration(
      border: Border(
        right: BorderSide(
          color: Colors.grey.shade300, // Or any color you prefer
          width: 1.0,
        ),
      ),
    ),
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
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                  child: Image.asset(
                    'assets/images/icons/logo.png',
                    width: 30,
                    height: 30,
                  ),
                ),
                const Text(
                  "Exper",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            _buildDrawerItem(context, "Dashboard", Icons.dashboard, 0),
            _buildDrawerItem(context, "Transactions", Icons.swap_horiz, 1),
            _buildDrawerItem(context, "Budgets", Icons.wallet, 2),
            _buildDrawerItem(context, "Reports", Icons.insert_chart, 3),
            _buildDrawerItem(context, "Settings", Icons.settings, 4),
          ],
        ),
        ListTile(
          leading: const CircleAvatar(),
          title: Obx(() => Text(authController.userName.value)),
          trailing: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ),
        SizedBox(
              height: 20,
            ),
      ],
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, int index) {
    return Obx(
      () => InkWell(
      
        onTap: () {
          homeController.changeTab(index);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: homeController.selectedIndex.value == index
              ? BoxDecoration(
                  color: Colors.black,
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: homeController.selectedIndex.value == index
                    ? Colors.white
                    : Colors.black,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: homeController.selectedIndex.value == index
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
