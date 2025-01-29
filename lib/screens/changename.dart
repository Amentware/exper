import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Exper/screens/userprofile.dart';
import 'package:Exper/widgets/colors.dart';

import '../firebase/auth_methods.dart';
import '../widgets/utils.dart';

class ChangeName extends StatefulWidget {
  const ChangeName({super.key});

  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  final TextEditingController _newnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _newnameController.dispose();
    _passwordController.dispose();
  }

  void changenamefunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await Authmethods().changename(
      newname: _newnameController.text,
      password: _passwordController.text,
    );
    if (res == 'success') {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, "Name Updated");
    } else {
      setState(() {
        _isLoading = false;
      });
      if (res ==
          "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
        showSnackBar(context, "Wrong Password");
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
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/backgrounds/Android Large - 17.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Change\nName',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Enter new Name To Update',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: _newnameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'New Name',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.account_circle_outlined,
                          color: lightorange,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: lightorange,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                    color: lightorange,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: lightorange,
                            borderRadius: BorderRadius.circular(50),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: changenamefunction,
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
                                          'Update',
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
          ],
        ),
      ),
    );
  }
}
