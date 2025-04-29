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
          child: SafeArea(
            child: SingleChildScrollView(child: _buildSidebar(context)),
          ),
        ),
        body: Obx(
          () => IndexedStack(
              index: homeController.selectedIndex.value,
              children: [
                Center(child: Text("Add Category Transactions Here")),
                Center(child: Text("Add Category2 Transactions Here")),
              ]),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "Menu",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _buildDrawerItem(
          context,
          "Dashboard",
          Icons.dashboard,
          0,
        ),
        _buildDrawerItem(
          context,
          "Add Category",
          Icons.category,
          1,
        ),
        const Divider(indent: 20, thickness: 1, endIndent: 20, height: 60),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "2021 Teamwork License",
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
          decoration: BoxDecoration(
            color: homeController.selectedIndex.value == index
                ? Colors.blue.shade100
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: homeController.selectedIndex.value == index
                      ? Colors.blue
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
