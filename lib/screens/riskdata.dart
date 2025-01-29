import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Exper/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'basicmaternalhealth.dart';

class MaternalRisk extends StatefulWidget {
  const MaternalRisk({super.key});

  @override
  State<MaternalRisk> createState() => _MaternalRiskState();
}

class _MaternalRiskState extends State<MaternalRisk> {
  var riskdata = {};
  String cid = "";
  bool isLoading = false;
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
      final prefs = await SharedPreferences.getInstance();
      cid = (prefs.getString('cid'))!;
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Maternal\nHealth Risk',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Predicts Maternal Health Risk level.\nPlease use this feature for awareness and precautions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Current Level:',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: purple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Image border
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
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
                                  color: purple,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: purple,
                          borderRadius: BorderRadius.circular(50),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              Get.to(
                                const BasicMaternalHealth(),
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
                              ),
                              child: const Text(
                                'Test',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Previous records:',
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
                ],
              ),
            ),
          ),
        );
  }
}
