import 'package:exper/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../widgets/colors.dart';
import '../widgets/utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void signUpFunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isLoading = true);

    String res = await authController.signUp(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (res == "success") {
      Get.offAll(HomeScreen(), transition: Transition.cupertino);
      showSnackBar(context, "Registration Successful");
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Text("Let's Start",
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900)),
              const SizedBox(height: 25),
              _buildTextField(_usernameController, 'Your Name',
                  Icons.account_circle_outlined),
              const SizedBox(height: 15),
              _buildTextField(
                  _emailController, 'Your Email', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField(
                  _passwordController, 'Password', Icons.lock_outline_rounded,
                  obscureText: true),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                        "Login",
                        orangeColor,
                        () => Get.off(const LoginPage(),
                            transition: Transition.cupertino),
                        isOutlined: true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildButton("Sign Up", orangeColor, signUpFunction,
                        isLoading: _isLoading),
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
        prefixIcon: Icon(icon, color: orangeColor),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap,
      {bool isOutlined = false, bool isLoading = false}) {
    return Material(
      color: isOutlined ? Colors.white : color,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.white : color,
            borderRadius: BorderRadius.circular(50),
            //border:
            //isOutlined ? Border.all(color: orangeColor, width: 2) : null,
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
                      color: isOutlined ? orangeColor : Colors.white,
                      fontWeight: FontWeight.w900),
                ),
        ),
      ),
    );
  }
}
