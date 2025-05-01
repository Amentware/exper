import 'package:exper/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_screen.dart';
import 'forgetpassword.dart';
import '../widgets/colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final AuthController authController = Get.find<AuthController>();

    void loginFunction() async {
      FocusManager.instance.primaryFocus?.unfocus();

      // Form validation
      if (emailController.text.trim().isEmpty) {
        Get.snackbar(
          "Validation Error",
          "Please enter your email",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

      if (!GetUtils.isEmail(emailController.text.trim())) {
        Get.snackbar(
          "Validation Error",
          "Please enter a valid email address",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

      if (passwordController.text.isEmpty) {
        Get.snackbar(
          "Validation Error",
          "Please enter your password",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

      // Show loading spinner while waiting for login response
      await authController.login(
          emailController.text.trim(), passwordController.text);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Welcome',
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Enter email and password to login',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  fillColor: const Color(0xFFF8F8F8),
                  filled: true,
                  prefixIcon: const Icon(Icons.email_outlined, color: black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  fillColor: const Color(0xFFF8F8F8),
                  filled: true,
                  prefixIcon:
                      const Icon(Icons.lock_outline_rounded, color: black),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () => Get.offAll(SignUpPage(),
                          transition: Transition.rightToLeft),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: black, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: loginFunction,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: black,
                        ),
                        child: Obx(
                          () => authController.isLoading.value
                              ? const SizedBox(
                                  height: 16.0,
                                  width: 16.0,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 4),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                alignment:
                    Alignment.centerRight, // Align the container to the right
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: InkWell(
                  onTap: () => Get.to(
                    ForgetPassword(),
                    transition:
                        Transition.rightToLeft, // Using Cupertino transition
                  ),
                  splashColor:
                      Colors.black.withOpacity(0.2), // Optional splash color
                  borderRadius: BorderRadius.circular(
                      5), // Make splash round by giving border radius
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        5), // Round the corners of the child widget
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.black, // Set the text color
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              )

/*
              InkWell(
                onTap: () =>
                    Get.to(ForgetPassword(), transition: Transition.cupertino),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                        color: black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
