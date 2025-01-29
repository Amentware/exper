import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Exper/firebase/auth_methods.dart';
import 'package:Exper/screens/clist.dart';
import 'package:Exper/screens/home.dart';
import 'package:Exper/screens/login.dart';
import '../widgets/colors.dart';
import '../widgets/utils.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _username = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _username.dispose();
  }

  void signuofunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    // set loading to true
    setState(() {
      _isLoading = true;
    });
    String res = await Authmethods().signUpUser(
      username: _username.text,
      email: _emailController.text,
      password: _passwordController.text,
      file: _image,
    );
    if (res ==
        "[firebase_auth/invalid-email] The email address is badly formatted.") {
      showSnackBar(context, "The email address is badly formatted");
    } else {
      showSnackBar(context, res);
    }
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      Get.offAll(const Childlist(), transition: Transition.cupertino);
      showSnackBar(context, "Registration Succesfully");
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      showSnackBar(context, res);
    }
  }

  selectImage() async {
    try {
      Uint8List im = await pickImage(ImageSource.gallery);
      setState(() {
        _image = im;
      });
    } catch (error) {
      showSnackBar(context, "No Image Selected");
    }
    // set state because we need to display the image we selected on the circle avatar
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
                'assets/images/backgrounds/Android Large - 2.png',
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Let's Start",
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: selectImage,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child:
                          _image != null
                              ? CircleAvatar(
                                radius: 64,
                                backgroundImage: MemoryImage(_image!),
                              )
                              : const CircleAvatar(
                                radius: 64,
                                backgroundImage: AssetImage(
                                  'assets/images/de7834s-6515bd40-8b2c-4dc6-a843-5ac1a95a8b55.jpg',
                                ),
                              ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Enter Your Personal Details to Sign Up',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _username,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Your Name',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.account_circle_outlined,
                    color: orangeColor,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Your Email',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: orangeColor,
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
                    color: orangeColor,
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
                          Get.off(
                            LoginPage(),
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
                            'Login',
                            style: TextStyle(
                              color: orangeColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: orangeColor,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        splashColor: const Color.fromARGB(255, 225, 52, 0),
                        borderRadius: BorderRadius.circular(50),
                        onTap: signuofunction,
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
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                  : const SizedBox(
                                    height: 15.0,
                                    width: 15.0,
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
