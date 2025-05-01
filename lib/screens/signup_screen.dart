import 'package:exper/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_screen.dart';
import '../widgets/colors.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final AuthController authController = Get.find<AuthController>();

    void signUpFunction() async {
      FocusManager.instance.primaryFocus?.unfocus();

      // Form validation
      if (usernameController.text.trim().isEmpty) {
        Get.snackbar(
          "Validation Error",
          "Please enter your name",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

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
          "Please enter a password",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

      if (passwordController.text.length < 6) {
        Get.snackbar(
          "Validation Error",
          "Password must be at least 6 characters long",
          backgroundColor: Colors.black,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(10),
        );
        return;
      }

      await authController.signUp(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Let's Start",
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Enter personal details to start savingggg',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 25),
              _buildTextField(
                  usernameController, 'Name', Icons.account_circle_outlined),
              const SizedBox(height: 15),
              _buildTextField(emailController, 'Email', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField(
                  passwordController, 'Password', Icons.lock_outline_rounded,
                  obscureText: true),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                        "Login",
                        black,
                        () => Get.offAll(const LoginPage(),
                            transition: Transition.leftToRight),
                        isOutlined: true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      // Reactively check if loading is true
                      return _buildButton("Sign Up", black, signUpFunction,
                          isLoading: authController.isLoading.value);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: const Color.fromARGB(255, 248, 248, 248),
        filled: true,
        prefixIcon: Icon(icon, color: black),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap,
      {bool isOutlined = false, bool isLoading = false}) {
    return Material(
      color: isOutlined ? Colors.white : color,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 4))
              : Text(
                  text,
                  style: TextStyle(
                      color: isOutlined ? black : Colors.white,
                      fontWeight: FontWeight.w900),
                ),
        ),
      ),
    );
  }
}
