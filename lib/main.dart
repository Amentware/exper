import 'package:exper/controllers/auth_controller.dart';
import 'package:exper/controllers/profile_controller.dart';
import 'package:exper/controllers/category_controller.dart';
import 'package:exper/controllers/transaction_controller.dart';
import 'package:exper/firebase_options.dart';
import 'package:exper/screens/home_screen.dart';
import 'package:exper/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize controllers
  Get.put(AuthController());
  Get.put(ProfileController());
  Get.put(CategoryController());
  Get.put(TransactionController());

  // Set status bar color to white and icons to black

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Background color of the status bar
      statusBarIconBrightness: Brightness.dark, // Icons/text in black
      systemNavigationBarColor:
          Colors.white, // Optional: Makes bottom nav bar white
      systemNavigationBarIconBrightness:
          Brightness.dark, // Makes bottom icons black
    ));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exper',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Obx(() {
      return authController.user.value != null ? HomeScreen() : LoginPage();
    });
  }
}
