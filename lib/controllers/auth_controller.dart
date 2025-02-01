import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> user = Rx<User?>(FirebaseAuth.instance.currentUser);
  RxBool isLoading = false.obs; // Reactive loading state

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  // Sign up with email & password
  Future<String> signUp(String username, String email, String password) async {
    try {
      isLoading.value = true; // Set loading to true during sign-up
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'username': username,
        'email': email,
        'uid': cred.user!.uid,
      });

      isLoading.value = false; // Set loading to false after operation
      Get.offAll(HomeScreen());
      return "success";
    } catch (e) {
      isLoading.value = false; // Set loading to false if error occurs
      Get.snackbar(
        "Sign Up Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white, // Set background color to white
        colorText: Colors.black, // Set text color to black
        snackStyle: SnackStyle.GROUNDED, // Optional style for a grounded look
      );
      return e.toString();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true; // Set loading to true during login
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isLoading.value = false; // Set loading to false after login
      Get.offAll(HomeScreen());
      Get.snackbar(
        "Login Successful",
        "You have successfully logged in.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white, // Set background color to white
        colorText: Colors.black, // Set text color to black
        snackStyle: SnackStyle.GROUNDED, // Optional: makes it grounded
      );
    } catch (e) {
      isLoading.value = false; // Set loading to false if error occurs
      Get.snackbar(
        "Login Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white, // Set background color to white
        colorText: Colors.black, // Set text color to black
        snackStyle: SnackStyle.GROUNDED, // Optional: grounded look
      );
    }
  }

  // Logout
  void logout() async {
    await _auth.signOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(LoginPage());
    });
  }

  // Forgot Password
  Future<String> forgetPassword(String email) async {
    try {
      isLoading.value = true; // Set loading to true
      await _auth.sendPasswordResetEmail(email: email); // Send reset email
      isLoading.value = false; // Set loading to false after operation
      return "Password reset link sent to your email!";
    } on FirebaseAuthException catch (e) {
      isLoading.value = false; // Set loading to false if error occurs
      Get.snackbar(
        "Error",
        e.message ?? "An unknown error occurred.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackStyle: SnackStyle.GROUNDED,
      );
      return e.message ?? "An unknown error occurred.";
    }
  }
}
