import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../controllers/profile_controller.dart';
import '../controllers/category_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Rx<User?> user = Rx<User?>(FirebaseAuth.instance.currentUser);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, (_) {
      if (user.value != null) {
        // Load user profile
        Get.find<ProfileController>().fetchUserProfile();
      }
    });
  }

  // Sign up
  Future<void> signUp(String username, String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Get the current month's start and end dates
      final now = DateTime.now();
      // Use UTC to avoid time zone offset issues when storing in Firestore
      final firstDayOfMonth = DateTime.utc(now.year, now.month, 1);
      final lastDayOfMonth = DateTime.utc(now.year, now.month + 1, 0);

      // Log the dates for debugging
      print(
          'First day of month: $firstDayOfMonth (${firstDayOfMonth.toIso8601String()})');
      print(
          'Last day of month: $lastDayOfMonth (${lastDayOfMonth.toIso8601String()})');

      // Create user profile with individual properties
      final profileData = {
        'name': username,
        'email': email,
        'auth_users_id': cred.user!.uid, // Firebase auth user ID
        'default_date_range': 'month',
        'custom_start_date': Timestamp.fromDate(firstDayOfMonth),
        'custom_end_date': Timestamp.fromDate(lastDayOfMonth),
        'currency': '₹', // Default currency symbol
        'theme': 'light', // Default theme
        'notification_enabled': true, // Default notification setting
        'created_at': Timestamp.fromDate(DateTime.now()),
        'updated_at': Timestamp.fromDate(DateTime.now()),
        'icon': 'default_profile', // Default profile icon/avatar
      };

      await _firestore
          .collection('profiles')
          .doc(cred.user!.uid)
          .set(profileData);

      // Create default categories explicitly for the new user
      final categoryController = Get.find<CategoryController>();
      await categoryController.createDefaultCategories(cred.user!.uid);

      // Delay slightly to ensure categories are properly loaded
      //await Future.delayed(Duration(milliseconds: 500));

      // Fetch categories again to make sure they're loaded in memory
      await categoryController.fetchCategories();

      isLoading.value = false;
      Get.offAll(HomeScreen());
    } catch (e) {
      isLoading.value = false;
      String errorMessage = 'An error occurred during sign up';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email is already in use.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
        }
      }
      Get.snackbar(
        "Sign Up Error",
        errorMessage,
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isLoading.value = false;
      Get.offAll(HomeScreen());
    } catch (e) {
      isLoading.value = false;
      String errorMessage = 'An error occurred during login';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'User not found.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password.';
            break;
        }
      }
      Get.snackbar(
        "Login Error",
        errorMessage,
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    }
  }

  // Logout
  void logout() async {
    await _auth.signOut();
    Get.offAll(LoginPage());
  }

  // Forgot Password
  Future<void> forgetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      isLoading.value = false;
      Get.snackbar(
        "Reset Mail Sent",
        "A password reset link has been sent to your email.",
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Reset Mail Error",
        e.toString(),
        colorText: Colors.white,
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
      );
    }
  }
}
