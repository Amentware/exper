import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Exper/screens/login.dart';
import '../firebase/auth_methods.dart';
import '../widgets/colors.dart';
import '../widgets/utils.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  void forgetpasswordfunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await Authmethods().forgetPassword(
      email: _emailController.text,
    );
    print(res);
    if (res ==
        "[firebase_auth/invalid-email] The email address is badly formatted.") {
      showSnackBar(context, "The email address is badly formatted");
    } else if (res ==
        "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
      showSnackBar(
        context,
        "There is no user record corresponding to this identifier. The user may have been deleted.",
      );
    } else {
      showSnackBar(context, res);
    }
    if (res == 'success') {
      setState(() {
        _isLoading = false;
      });
      // navigate to the login screen
      showSnackBar(context, "Password reset link send to your Email");
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, res);
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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/backgrounds/Android Large - 4.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
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
                  'Password',
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Enter Email To Reset Your Password',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
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
                        onTap: forgetpasswordfunction,
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
                                    'Reset',
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
            ],
          ),
        ),
      ),
    );
  }
}
