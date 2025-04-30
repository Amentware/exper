import 'package:exper/controllers/auth_controller.dart';
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
  Get.put(AuthController()); // Initialize AuthController

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
