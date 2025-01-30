import 'package:exper/firebase/auth_methods.dart';
import 'package:exper/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exper/screens/userprofile.dart';
import 'package:exper/widgets/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userData = {};
  var babyData = {};
  var child = {};
  var dailytips = {};
  var week = 0;
  var days = 0;
  var daysLeft = 0;
  var noOfDates = 0;
  String cid = "";
  String weekmeg = '';
  bool isLoading = false;
  var riskdata = {};

  @override
  void initState() {
    super.initState();
    isLoading = false;
    //getData();
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

      if (userSnap.data() != null) {
        userData = userSnap.data()!;

        if (userData['childid'] == null) {
          babyData = {};
          dailytips = {};
          riskdata = {};
          week = 0;
          days = 0;
          daysLeft = 0;
          weekmeg = '0';
          return;
        }
        cid = userData['childid'];
        try {
          var babySnap =
              await FirebaseFirestore.instance
                  .collection('babyinfo')
                  .doc(cid)
                  .get();
          if (babySnap.exists) {
            babyData = babySnap.data()!;
          } else {
            babyData = {};
          }
        } catch (e) {
          print('Error fetching baby data: $e');
        }

        try {
          var tipsSnap =
              await FirebaseFirestore.instance
                  .collection('dailytips')
                  .doc(cid)
                  .get();
          if (tipsSnap.exists) {
            dailytips = tipsSnap.data()!;
          } else {
            dailytips = {};
          }
        } catch (e) {
          print('Error fetching daily tips: $e');
        }

        try {
          var riskSnap =
              await FirebaseFirestore.instance
                  .collection('risk')
                  .doc(cid)
                  .get();
          if (riskSnap.exists) {
            riskdata = riskSnap.data()!;
          } else {
            riskdata = {};
          }
        } catch (e) {
          print('Error fetching risk data: $e');
        }

        // Calculate pregnancy metrics
        if (userData['duedate'] != null) {
          DateTime dueDate = userData['duedate'].toDate();
          DateTime now = DateTime.now();
          daysLeft = dueDate.difference(now).inDays;
          if (daysLeft < 0) daysLeft = 0;

          // Calculate the number of weeks since the start of pregnancy (assuming 40 weeks total)
          final startOfPregnancy = dueDate.subtract(
            const Duration(days: 280),
          ); // 40 weeks * 7 days/week
          final daysSinceStart = now.difference(startOfPregnancy).inDays;
          week = (daysSinceStart / 7).floor();
          days = daysSinceStart % 7;
          if (week < 0) week = 0;
          if (week > 40) week = 40;
          if (days < 0) days = 0;
          if (days > 6) days = 6;
          weekmeg = 'Week $week, Day $days';
        } else {
          week = 0;
          days = 0;
          daysLeft = 0;
          weekmeg = '0';
        }
      } else {
        userData = {};
        babyData = {};
        dailytips = {};
        riskdata = {};
        daysLeft = 0;
        week = 0;
      }
      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void signoutfunction() {
    Get.offAll(LoginPage());
    Authmethods().signOut();
  }

  String greetingMessage() {
    var timeNow = DateTime.now().hour;

    if (timeNow < 12) {
      return 'Good Morning';
    } else if ((timeNow >= 12) && (timeNow <= 16)) {
      return 'Good Afternoon';
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                color: grey,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    //Good Moring
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Text(
                              greetingMessage(),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                const UserProfile(),
                                transition: Transition.cupertino,
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: whiteColor,
                              backgroundImage: const AssetImage(
                                'assets/images/user.jpg',
                              ),
                              // Use a default asset image if photoUrl is null
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
