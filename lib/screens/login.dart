import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exper/firebase/auth_methods.dart';
import 'package:exper/screens/forgetpassword.dart';
import 'package:exper/screens/home.dart';
import 'package:exper/screens/signup.dart';
import 'package:exper/widgets/utils.dart';

import '../widgets/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginfunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await Authmethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (res == 'success') {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      Get.offAll(const HomeScreen(), transition: Transition.cupertino);
      showSnackBar(context, "Login Succesfully");
    } else {
      setState(() {
        _isLoading = false;
      });
      print(res);
      if (res ==
          "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
        showSnackBar(context, "Wrong Password or Email");
      } else if (res ==
          "[firebase_auth/invalid-email] The email address is badly formatted.") {
        showSnackBar(context, "The email address is badly formatted");
      } else {
        showSnackBar(context, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          alignment: Alignment.bottomCenter,
          constraints: const BoxConstraints.expand(),
          /*
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/backgrounds/Android Large - 2.png',
              ),
              fit: BoxFit.cover,
            ),
          ),*/
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Enter your email and password to login',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: blueColor,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                autocorrect: false,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Password',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: blueColor,
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
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      child: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(50),
                        ),
                        onTap: () {
                          Get.off(
                            const Signuppage(),
                            transition: Transition.cupertino,
                          );
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

                            /*gradient: LinearGradient(
                              colors: [
                                Color(0xff003E87),
                                Color(0xFF0075FF),
                                
                              ],
                              stops: [
                                0.0,
                                1.0
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              tileMode: TileMode.repeated),*/
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        splashColor: Color.fromARGB(255, 0, 89, 255),
                        borderRadius: BorderRadius.circular(50),
                        onTap: loginfunction,
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
                          child:
                              !_isLoading
                                  ? const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                  : const SizedBox(
                                    height: 16.0,
                                    width: 16.0,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 4,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Get.to(
                    const ForgetPassword(),
                    transition: Transition.cupertino,
                  );
                },
                splashColor: blueColor,
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: blueColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
