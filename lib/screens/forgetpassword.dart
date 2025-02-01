import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart'; // Assuming AuthController is in controllers folder
import '../widgets/colors.dart';

class ForgetPassword extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final AuthController authController =
      Get.find<AuthController>(); // Get instance of AuthController

  void forgetPasswordFunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await authController.forgetPassword(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Text(
                'Password',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Enter Email To Reset Your Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Your Email',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: yellowColor,
                  ),
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
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(15),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: yellowColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        splashColor: const Color.fromARGB(255, 251, 138, 38),
                        borderRadius: BorderRadius.circular(50),
                        onTap: forgetPasswordFunction,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(15),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                          child: Obx(() {
                            if (authController.isLoading.value) {
                              return const SizedBox(
                                height: 16.0,
                                width: 16.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 4,
                                ),
                              );
                            } else {
                              return const Text(
                                'Reset',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
