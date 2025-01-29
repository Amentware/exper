import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/Prediction.dart';
import '../widgets/utils.dart';
import 'home.dart';
import '../widgets/colors.dart';

class Anemiaprediction extends StatefulWidget {
  const Anemiaprediction({super.key});

  @override
  State<Anemiaprediction> createState() => _AnemiapredictionState();
}

class _AnemiapredictionState extends State<Anemiaprediction> {
  String info = '''Iron deficiency anemia during pregnancy: Prevention tips
Iron deficiency anemia during pregnancy can make you feel weak and tired. Know the risk factors and symptoms and what you can do to avoid the condition.

If you're pregnant, you're at increased risk of iron deficiency anemia. Iron deficiency anemia is a condition in which you don't have enough healthy red blood cells to carry adequate oxygen to the body's tissues. Find out why anemia during pregnancy occurs and what you can do to prevent it.

What causes iron deficiency anemia during pregnancy?
Your body uses iron to make hemoglobin. Hemoglobin is a protein in the red blood cells that carries oxygen to your tissues. During pregnancy, the volume of blood in your body increases, and so does the amount of iron you need. Your body uses iron to make more blood to supply oxygen to your baby. If you don't have enough iron stores or get enough iron during pregnancy, you could develop iron deficiency anemia.

How does iron deficiency anemia during pregnancy affect the baby?
Severe iron deficiency anemia during pregnancy increases the risk of premature birth (when delivery occurs before 37 complete weeks of pregnancy). Iron deficiency anemia during pregnancy is also associated with having a low birth weight baby and postpartum depression. Some studies also show an increased risk of infant death immediately before or after birth.

What are the risk factors for iron deficiency anemia during pregnancy?
You are at increased risk of developing anemia during pregnancy if you:

Have two closely spaced pregnancies
Are pregnant with more than one baby
Are vomiting frequently due to morning sickness
Don't consume enough iron-rich foods
Have a heavy pre-pregnancy menstrual flow
Have a history of anemia before your pregnancy
What are the symptoms of iron deficiency anemia during pregnancy?
Anemia signs and symptoms include:

Fatigue
Weakness
Dizziness or lightheadedness
Headache
Pale or yellowish skin
Shortness of breath
Craving or chewing ice (pica)
Symptoms of severe anemia may include:

A rapid heartbeat
Low blood pressure
Difficulty concentrating
Keep in mind, however, that symptoms of anemia are often similar to general pregnancy symptoms. Regardless of whether or not you have symptoms, you'll have blood tests to screen for anemia during pregnancy. If you're concerned about your level of fatigue or any other symptoms, talk to your health care provider.

How can iron deficiency anemia during pregnancy be prevented and treated?
Prenatal vitamins typically contain iron. Taking a prenatal vitamin that contains iron can help prevent and treat iron deficiency anemia during pregnancy. In some cases, your health care provider might recommend a separate iron supplement. During pregnancy, you need 27 milligrams of iron a day.

Good nutrition can also prevent iron deficiency anemia during pregnancy. Dietary sources of iron include lean red meat, poultry and fish. Other options include iron-fortified breakfast cereals, dark green leafy vegetables, dried beans and peas.

The iron from animal products, such as meat, is most easily absorbed. To enhance the absorption of iron from plant sources and supplements, pair them with a food or drink high in vitamin C — such as orange juice, tomato juice or strawberries. If you take iron supplements with orange juice, avoid the calcium-fortified variety. Although calcium is an essential nutrient during pregnancy, calcium can decrease iron absorption.

How is iron deficiency anemia during pregnancy treated?
If you are taking a prenatal vitamin that contains iron and you are anemic, your health care provider might recommend testing to determine other possible causes. In some cases, you might need to see a doctor who specializes in treating blood disorders (hematologist). If the cause is iron deficiency, your health care provider may recommend additional supplemental iron. If you have a history of gastric bypass or small bowel surgery or are unable to tolerate oral iron supplementation, you might need to have iron administered through a needle placed into one of your veins (intravenous administration).''';
  final TextEditingController _Hemoglobin = TextEditingController();
  final TextEditingController _MCH = TextEditingController();
  final TextEditingController _MCHC = TextEditingController();
  final TextEditingController _MCV = TextEditingController();
  bool _isLoading = false;
  bool isLoading = false;
  String cid = "";
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
      setState(() {});
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _Hemoglobin.dispose();
    _MCH.dispose();
    _MCHC.dispose();
    _MCV.dispose();
  }

  void validate() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_Hemoglobin.text.isNotEmpty &&
        _MCH.text.isNotEmpty &&
        _MCHC.text.isNotEmpty &&
        _MCV.text.isNotEmpty) {
      if (double.parse(_Hemoglobin.text) >= 6.6 &&
          double.parse(_Hemoglobin.text) <= 16.9) {
        if (double.parse(_MCH.text) >= 16 && double.parse(_MCH.text) <= 30) {
          if (double.parse(_MCHC.text) >= 27.8 &&
              double.parse(_MCHC.text) <= 32.5) {
            if (double.parse(_MCV.text) >= 69.4 &&
                double.parse(_MCV.text) <= 101.6) {
              anemiapredictionfunction();
            } else {
              showSnackBar(context, "MCV must be below 101.6 and above 69.4!");
            }
          } else {
            showSnackBar(context, "MCHC must be below 32.5 and above 27.8!");
          }
        } else {
          showSnackBar(context, "MCH must be below 30 and above 16!");
        }
      } else {
        showSnackBar(context, "Hemoglobin must be below 16.5 and above 6.6!");
      }
    } else {
      showSnackBar(context, "Enter all Values!!");
    }
  }

  void anemiapredictionfunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await Prediction().anemiadetection(
        Hemoglobin: _Hemoglobin.text,
        MCH: _MCH.text,
        MCHC: _MCHC.text,
        MCV: _MCV.text);
    if (res == "1" || res == "0") {
      setState(() {
        _isLoading = false;
      });
      if (res == '0') {
        _onBasicAlertPressed(context, "No Anemia");
      } else {
        _onBasicAlertPressed(context, "You have Anemia");
      }
    } else if (res ==
        "type 'Null' is not a subtype of type 'FutureOr<String>'") {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, "Please enter all the fields");
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  _onBasicAlertPressed(context, resp) {
    Alert(
      context: context,
      title: "Predicted Anemia",
      desc: resp,
      buttons: [
        DialogButton(
          color: yellowColor,
          onPressed: () {
            Get.offAll(const HomeScreen(), transition: Transition.cupertino);
            Get.reloadAll();
          },
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: whiteColor,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Anemia\nDetection',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Enter your Observed Data to detect Anemia',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: _Hemoglobin,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Hemoglobin(6.6-16.5 )',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.format_list_numbered,
                          color: blueColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    TextField(
                      controller: _MCH,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'MCH(16-30)',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.medical_services,
                          color: blueColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    TextField(
                      controller: _MCHC,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'MCHC(27.8-32.5 )',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.low_priority_rounded,
                          color: blueColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    TextField(
                      controller: _MCV,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'MCV(69.4-101.6)',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.bloodtype,
                          color: blueColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(50),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                Navigator.of(context).pop();
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
                            color: blueColor,
                            borderRadius: BorderRadius.circular(50),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: validate,
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
                                child: !_isLoading
                                    ? const Text(
                                        'Predict',
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
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Previous records:',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: blueColor),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                      ),
                      //padding: const EdgeInsets.symmetric(
                      //  vertical: 30, horizontal: 15),
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Predictions')
                              .doc(cid)
                              .collection('Anemia')
                              .orderBy('date', descending: true)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text("No records!"),
                              );
                            }
                            return Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (ctx, index) => Container(
                                  child: Column(
                                    children: [
                                      Material(
                                        color: const Color.fromARGB(
                                            255, 248, 248, 248),
                                        borderRadius: BorderRadius.circular(20),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () {},
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 20),
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
                                                            FontWeight.w500),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  const Text(
                                                    ":",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  snapshot.data!.docs[index]
                                                              .data()[
                                                                  'anemiaornot']
                                                              .toString() ==
                                                          '1'
                                                      ? const Text(
                                                          "Anemia",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        )
                                                      : const Text(
                                                          "no Anemia",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                ],
                                              )),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(
                              height: 18,
                            ),
                            InkWell(
                              onTap: () {},
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
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          15), // Image border
                                      child: SizedBox.fromSize(
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
                                          child: Text(info),
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
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              decoration: const ShapeDecoration(
                                color: darkpink,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                  Radius.circular(50),
                                )),
                              ),
                              child: const Text(
                                'Read about Anemia in Pregnancy',
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
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
