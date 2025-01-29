import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Exper/screens/duedate.dart';
import 'package:Exper/screens/home.dart';
import 'package:Exper/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Childlist extends StatefulWidget {
  const Childlist({super.key});

  @override
  State<Childlist> createState() => _ChildlistState();
}

class _ChildlistState extends State<Childlist> {
  late String cid = '';
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      cid = prefs.getString('cid')!;
    } catch (e) {
      cid = '';
    }
    setState(() {});
  }

  void setcid({required String cid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cid', cid);
    Get.offAll(const HomeScreen(), transition: Transition.cupertino);
  }

  @override
  Widget build(BuildContext context) {
    if (cid != '') {
      return const HomeScreen();
    } else {
      return Scaffold(
        body: StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection('child')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('children')
                  .snapshots(),
          builder: (
            context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              body: Stack(
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
                    physics: const ScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 100),
                        Container(
                          alignment: Alignment.topLeft,
                          child: const Text(
                            'Select Baby',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: const Text(
                            'Select nicknames of the baby or Create new.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                        borderRadius: BorderRadius.circular(20),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          onTap: () {
                                            setcid(
                                              cid:
                                                  snapshot.data!.docs[index]
                                                      .data()['cid']
                                                      .toString(),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 20,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              snapshot.data!.docs[index]
                                                  .data()['nickname']
                                                  .toString(),
                                              style: const TextStyle(
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
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(50),
                                  ),
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
                                      '',
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
                                color: lightblue,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  splashColor: Color.fromARGB(255, 0, 89, 255),
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    Get.to(
                                      const dueDate(),
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
                                      'New Baby',
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
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }
}
