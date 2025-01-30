import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:exper/screens/userprofile.dart';
import 'package:exper/widgets/colors.dart';

import '../firebase/auth_methods.dart';

import '../widgets/utils.dart';

class ChangePhoto extends StatefulWidget {
  const ChangePhoto({super.key});

  @override
  State<ChangePhoto> createState() => _ChangePhotoState();
}

class _ChangePhotoState extends State<ChangePhoto> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool isLoading = false;
  var userData = {};

  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  void changephotofunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await Authmethods().changephoto(
      file: _image,
      password: _passwordController.text,
    );
    if (res == 'success') {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, "Photo Updated");
      Navigator.of(context).pop();
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const UserProfile()));
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
    return isLoading
        ? const Scaffold(body: Center())
        : Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/backgrounds/Android Large - 18.png',
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
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Change\nPhoto",
                                style: TextStyle(
                                  fontSize: 45,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: selectImage,
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child:
                                    _image != null
                                        ? CircleAvatar(
                                          radius: 64,
                                          backgroundImage: MemoryImage(_image!),
                                        )
                                        : CircleAvatar(
                                          radius: 64,
                                          backgroundImage: NetworkImage(
                                            userData['photoUrl'],
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          alignment: Alignment.topLeft,
                          child: const Text(
                            'Tap on Old Photo to Select',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
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
                              color: darkpink,
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
                                        color: darkpink,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Material(
                                color: darkpink,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: changephotofunction,
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
