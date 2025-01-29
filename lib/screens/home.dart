import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Exper/screens/afterdelivery.dart';
import 'package:Exper/screens/anemiaprediction.dart';
import 'package:Exper/screens/gdm.dart';
import 'package:Exper/screens/riskdata.dart';
import 'package:Exper/screens/timeline.dart';
import 'package:Exper/screens/userprofile.dart';
import 'package:Exper/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      cid = (prefs.getString('cid'))!;
      var childSnap =
          await FirebaseFirestore.instance
              .collection('child')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('children')
              .doc(cid)
              .get();
      child = childSnap.data()!;
      DateTime firstDay = DateTime.parse(child['firstDay']);
      DateTime dueDate = DateTime.parse(child['dueDate']);
      DateTime now = DateTime.now();
      final difference = now.difference(firstDay).inDays;
      daysLeft = dueDate.difference(now).inDays + 1;
      if (daysLeft < 0) {
        Get.offAll(const AfterDelivery(), transition: Transition.cupertino);
      }
      noOfDates = (difference) - 6;
      week = (difference / 7).floor();
      days = (difference % 7);
      if (days == 0) {
        weekmeg = '$week Weeks';
      } else {
        weekmeg = '$week Weeks & $days Days';
      }
      var dailySnap =
          await FirebaseFirestore.instance
              .collection('dailyupdate')
              .doc(noOfDates.toString())
              .get();
      dailytips = dailySnap.data()!;
      var babySnap =
          await FirebaseFirestore.instance
              .collection('babydetails')
              .doc(week.toString())
              .get();
      babyData = babySnap.data()!;
      var risksnap =
          await FirebaseFirestore.instance
              .collection('Predictions')
              .doc(cid)
              .get();
      riskdata = risksnap.data()!;
      setState(() {});
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
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
                              backgroundImage: NetworkImage(
                                userData['photoUrl'],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    //Weeks
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  'You are pregnant for',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  weekmeg,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    color: yellowColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              Get.to(
                                const TimeLine(),
                                transition: Transition.cupertino,
                              );
                            },
                            child: const Icon(
                              Icons.calendar_month,
                              size: 40,
                              color: yellowColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Image border
                          child: SizedBox.fromSize(
                            // Image radius
                            child: Image(
                              image: AssetImage(
                                'assets/images/babypic/pregnancy-week-$week.jpg',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 240,
                          alignment: Alignment.bottomLeft,
                          decoration: const ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topCenter,
                              stops: [0.2, 0.8, 1],
                              colors: [
                                Colors.black,
                                Colors.black12,
                                Colors.transparent,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Weight: ',
                                    style: TextStyle(
                                      color: greydark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    babyData['weight']!,
                                    style: const TextStyle(
                                      color: whiteColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Length: ',
                                    style: TextStyle(
                                      color: greydark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    babyData['length']!,
                                    style: const TextStyle(
                                      color: whiteColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.centerLeft,
                              decoration: const ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    color: greydark,
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                                color: whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                              ),
                              //padding: const EdgeInsets.symmetric(
                              //  vertical: 30, horizontal: 15),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    dailytips['meg'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              decoration: const ShapeDecoration(
                                color: blueColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Daily Tips & Updations',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.centerLeft,
                              decoration: const ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    color: greydark,
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                                color: whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                              ),
                              //padding: const EdgeInsets.symmetric(
                              //  vertical: 30, horizontal: 15),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: const ShapeDecoration(
                                          color: Color(0xffFFF0B8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(50),
                                            ),
                                          ),
                                        ),
                                        child: null,
                                      ),
                                      Container(
                                        height: 40,
                                        width:
                                            ((320 - daysLeft) / 289 * 100) /
                                            (MediaQuery.of(
                                              context,
                                            ).size.width) *
                                            1000,
                                        alignment: Alignment.center,
                                        decoration: const ShapeDecoration(
                                          color: yellowColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(50),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          daysLeft.toString(),
                                          style: const TextStyle(
                                            color: whiteColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              decoration: const ShapeDecoration(
                                color: lightgreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Days Left',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 18),
                            InkWell(
                              onTap: () {
                                Get.to(
                                  const MaternalRisk(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: const ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      color: greydark,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  color: whiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                                //padding: const EdgeInsets.symmetric(
                                //  vertical: 30, horizontal: 15),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ), // Image border
                                      child: SizedBox.fromSize(
                                        child:
                                            riskdata['MaternalRisk'] != null
                                                ? Image(
                                                  image: AssetImage(
                                                    'assets/images/pngs/${riskdata['MaternalRisk']}.png',
                                                  ),
                                                )
                                                : const Image(
                                                  image: AssetImage(
                                                    'assets/images/pngs/Frame 13.png',
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              decoration: const ShapeDecoration(
                                color: darkpink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Maternal Risk Level',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 18),
                            InkWell(
                              onTap: () {
                                Get.to(
                                  const Anemiaprediction(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: const ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      color: greydark,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  color: whiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                                //padding: const EdgeInsets.symmetric(
                                //  vertical: 30, horizontal: 15),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ), // Image border
                                      child: SizedBox.fromSize(
                                        child:
                                            riskdata['anemiaornot'] != null
                                                ? Image(
                                                  image: AssetImage(
                                                    'assets/images/pngs/anemia${riskdata['anemiaornot']}.png',
                                                  ),
                                                )
                                                : const Image(
                                                  image: AssetImage(
                                                    'assets/images/pngs/anemia.png',
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              decoration: const ShapeDecoration(
                                color: lightgreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Anemia Detection',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 18),
                            InkWell(
                              onTap: () {
                                Get.to(
                                  const GDM(),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: const ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      color: greydark,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  color: whiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                ),
                                //padding: const EdgeInsets.symmetric(
                                //  vertical: 30, horizontal: 15),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ), // Image border
                                      child: SizedBox.fromSize(
                                        child:
                                            riskdata['gdmornot'] != null
                                                ? Image(
                                                  image: AssetImage(
                                                    'assets/images/pngs/gdm${riskdata['gdmornot']}.png',
                                                  ),
                                                )
                                                : const Image(
                                                  image: AssetImage(
                                                    'assets/images/pngs/Frame 12.png',
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              decoration: const ShapeDecoration(
                                color: purple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'GDM Status',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
