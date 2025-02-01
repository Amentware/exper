import 'package:exper/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final HomeController homeController = Get.put(HomeController());

  final List<Widget> pages = [
    Center(child: Text("Expenses")),
    Center(child: Text("Summary")),
    Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text("Hello, ${authController.userName.value}")),
        ),
        body: Obx(() => pages[homeController.selectedIndex.value]),
        bottomNavigationBar: Obx(() => BottomNavigationBar(
              currentIndex: homeController.selectedIndex.value,
              onTap: homeController.changeTab,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.money), label: "Expenses"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart), label: "Summary"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
              ],
            )),
      ),
    );
  }
}
