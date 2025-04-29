import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> user = Rx<User?>(FirebaseAuth.instance.currentUser);
  RxBool isLoading = false.obs;
  RxString userName = ''.obs; // Reactive username

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user,
        (_) => fetchUserData()); // Fetch user data when auth state changes
  }

  // Fetch user data from Firestore
  void fetchUserData() async {
    if (user.value != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.value!.uid)
          .get();
      userName.value = userData['username'] ?? 'User';
    } else {
      userName.value = '';
    }
  }

  // Sign up
  Future<void> signUp(String username, String email, String password) async {
    try {
      isLoading.value = true;
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
 colorText: Colors.black,
        backgroundColor: Colors.white,
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
 colorText: Colors.black,
        backgroundColor: Colors.white,
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      showErrorSnackbar("Error", e.toString());
    }
  }

  // Utility method for displaying errors
  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
