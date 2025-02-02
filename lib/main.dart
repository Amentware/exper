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
        primarySwatch: Palette.kToDark,
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

class Palette {
  static const MaterialColor kToDark = MaterialColor(
    0xf6750a4, // Base colo
    <int, Color>{
      50: Color(0xffE3F2FD), // 10% - Light Blue
      100: Color(0xffBBDEFB), // 20%
      200: Color(0xff90CAF9), // 30%
      300: Color(0xff64B5F6), // 40%
      400: Color(0xff42A5F5), // 50%
      500: Color(0xff2196F3), // 60% - Primary Blue
      600: Color(0xff1E88E5), // 70%
      700: Color(0xff1976D2), // 80%
      800: Color(0xff1565C0), // 90%
      900: Color(0xff0D47A1), // 100% - Darkest Shade
    },
  );
}
