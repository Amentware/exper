import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:Exper/screens/changemail.dart';
import 'package:Exper/screens/changename.dart';
import 'package:Exper/screens/changepassword.dart';
import 'package:Exper/screens/changephoto.dart';
import 'package:Exper/screens/login.dart';
import 'package:Exper/widgets/colors.dart';
import '../firebase/auth_methods.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  void signoutfunction() {
    Get.offAll(LoginPage());
    Authmethods().signOut();
  }

  User user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
          if (snap.hasData) {
            return SafeArea(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/backgrounds/Android Large - 13.png',
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {},
                                  child: Text(
                                    "Hi,${snap.data!['username']}",
                                    style: const TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      snap.data!['photoUrl'],
                                    ),
                                    backgroundColor: whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: const Text(
                              'Tap on name or photo to edit',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Material(
                            color: const Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Get.to(
                                  const ChangeEmail(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Change Email",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Material(
                            color: const Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Get.to(
                                  const ChangePassword(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Change Password",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Material(
                            color: const Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Get.to(
                                  const ChangePhoto(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Change Profile Photo",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Material(
                            color: const Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Get.to(
                                  const ChangeName(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Change name",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Material(
                            color: const Color.fromARGB(255, 248, 248, 248),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: signoutfunction,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Sign out",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
