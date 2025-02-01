import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> user = Rx<User?>(FirebaseAuth.instance.currentUser);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  // Sign up with email & password
  Future<String> signUp(String username, String email, String password) async {
    try {
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

      Get.offAll(HomeScreen());
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(HomeScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Logout
  void logout() async {
    await _auth.signOut();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(LoginPage());
    });
  }
}
