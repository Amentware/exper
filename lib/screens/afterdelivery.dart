import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Exper/screens/userprofile.dart';
import 'package:Exper/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AfterDelivery extends StatefulWidget {
  const AfterDelivery({super.key});

  @override
  State<AfterDelivery> createState() => _AfterDeliveryState();
}

class _AfterDeliveryState extends State<AfterDelivery> {
  var userData = {};
  String cid = "";
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
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'GDM records:',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: orangeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.topLeft,

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
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      //padding: const EdgeInsets.symmetric(
                      //  vertical: 30, horizontal: 15),
                      child: StreamBuilder(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Predictions')
                                .doc(cid)
                                .collection('GDM')
                                .orderBy('date', descending: true)
                                .snapshots(),
                        builder: (
                          context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData) {
                            return Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder:
                                    (ctx, index) => Container(
                                      child: Column(
                                        children: [
                                          Material(
                                            color: const Color.fromARGB(
                                              255,
                                              248,
                                              248,
                                              248,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              onTap: () {},
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 20,
                                                    ),
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      snapshot.data!.docs[index]
                                                          .data()['date']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    snapshot.data!.docs[index]
                                                                .data()['gdmornot']
                                                                .toString() ==
                                                            '1'
                                                        ? const Text(
                                                          "You have GDM",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        )
                                                        : const Text(
                                                          "NO GDM",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                        ],
                                      ),
                                    ),
                              ),
                            );
                          }
                          return const Text("No records!");
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Maternal Risk records:',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.topLeft,

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
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      //padding: const EdgeInsets.symmetric(
                      //  vertical: 30, horizontal: 15),
                      child: StreamBuilder(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Predictions')
                                .doc(cid)
                                .collection('MaternalRisk')
                                .orderBy('date', descending: true)
                                .snapshots(),
                        builder: (
                          context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData) {
                            return Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder:
                                    (ctx, index) => Container(
                                      child: Column(
                                        children: [
                                          Material(
                                            color: const Color.fromARGB(
                                              255,
                                              248,
                                              248,
                                              248,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              onTap: () {},
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 20,
                                                    ),
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      snapshot.data!.docs[index]
                                                          .data()['date']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      snapshot.data!.docs[index]
                                                          .data()['risk']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                        ],
                                      ),
                                    ),
                              ),
                            );
                          }
                          return const Text("No records!");
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 30),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Previous records:',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: blueColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.topLeft,

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
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      //padding: const EdgeInsets.symmetric(
                      //  vertical: 30, horizontal: 15),
                      child: StreamBuilder(
                        stream:
                            FirebaseFirestore.instance
                                .collection('Predictions')
                                .doc(cid)
                                .collection('Anemia')
                                .orderBy('date', descending: true)
                                .snapshots(),
                        builder: (
                          context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text("No records!"));
                          }
                          return Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder:
                                  (ctx, index) => Container(
                                    child: Column(
                                      children: [
                                        Material(
                                          color: const Color.fromARGB(
                                            255,
                                            248,
                                            248,
                                            248,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            onTap: () {},
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 20,
                                                  ),
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                children: [
                                                  Text(
                                                    snapshot.data!.docs[index]
                                                        .data()['date']
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const Text(
                                                    ":",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  snapshot.data!.docs[index]
                                                              .data()['anemiaornot']
                                                              .toString() ==
                                                          '1'
                                                      ? const Text(
                                                        "Anemia",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      )
                                                      : const Text(
                                                        "no Anemia",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
