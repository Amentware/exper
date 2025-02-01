import 'package:Exper/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_screen.dart';
import 'forgetpassword.dart';
import '../widgets/colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final AuthController authController = Get.find<AuthController>();

    void loginFunction() async {
      FocusManager.instance.primaryFocus?.unfocus();

      // Show loading spinner while waiting for login response
      await authController.login(
          _emailController.text, _passwordController.text);
    }

    return Scaffold(
      appBar: AppBar(),
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  fillColor: const Color(0xFFF8F8F8),
                  filled: true,
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: blueColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  fillColor: const Color(0xFFF8F8F8),
                  filled: true,
                  prefixIcon:
                      const Icon(Icons.lock_outline_rounded, color: blueColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => Get.offAll(SignUpPage(),
                          transition: Transition.rightToLeft),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: blueColor, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: loginFunction,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: blueColor,
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
                      Colors.blue.withOpacity(0.2), // Optional splash color
                  borderRadius: BorderRadius.circular(
                      30), // Make splash round by giving border radius
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        30), // Round the corners of the child widget
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue, // Set the text color
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
                        color: blueColor,
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
