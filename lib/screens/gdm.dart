import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exper/screens/home.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/Prediction.dart';
import '../widgets/colors.dart';
import '../widgets/utils.dart';

class GDM extends StatefulWidget {
  const GDM({super.key});

  @override
  State<GDM> createState() => _GDMState();
}

class _GDMState extends State<GDM> {
  String info = '''What is gestational diabetes mellitus?
Gestational diabetes mellitus (GDM)  is a condition in which a hormone made by the placenta prevents the body from using insulin effectively. Glucose builds up in the blood instead of being absorbed by the cells.

Unlike type 1 diabetes, gestational diabetes is not caused by a lack of insulin, but by other hormones produced during pregnancy that can make insulin less effective, a condition referred to as insulin resistance. Gestational diabetic symptoms disappear following delivery.

Approximately 3 to 8 percent of all pregnant women in the United States are diagnosed with gestational diabetes.

What causes gestational diabetes mellitus?
Although the cause of GDM is not known, there are some theories as to why the condition occurs.

The placenta supplies a growing fetus with nutrients and water, and also produces a variety of hormones to maintain the pregnancy. Some of these hormones (estrogen, cortisol, and human placental lactogen) can have a blocking effect on insulin. This is called contra-insulin effect, which usually begins about 20 to 24 weeks into the pregnancy.

As the placenta grows, more of these hormones are produced, and the risk of insulin resistance becomes greater. Normally, the pancreas is able to make additional insulin to overcome insulin resistance, but when the production of insulin is not enough to overcome the effect of the placental hormones, gestational diabetes results.

What are the risks factors associated with gestational diabetes mellitus?
Although any woman can develop GDM during pregnancy, some of the factors that may increase the risk include the following:

Overweight or obesity

Family history of diabetes

Having given birth previously to an infant weighing greater than 9 pounds

Age (women who are older than 25 are at a greater risk for developing gestational diabetes than younger women)

Race (women who are African-American, American Indian, Asian American, Hispanic or Latino, or Pacific Islander have a higher risk)

Prediabetes, also known as impaired glucose tolerance

Although increased glucose in the urine is often included in the list of risk factors, it is not believed to be a reliable indicator for GDM.

How is gestational diabetes mellitus diagnosed?
The American Diabetes Association recommends screening for undiagnosed type 2 diabetes at the first prenatal visit in women with diabetes risk factors. In pregnant women not known to have diabetes, GDM testing should be performed at 24 to 28 weeks of gestation.

In addition, women with diagnosed GDM should be screened for persistent diabetes 6 to 12 weeks postpartum. It is also recommended that women with a history of GDM undergo lifelong screening for the development of diabetes or prediabetes at least every three years.

What is the treatment for gestational diabetes mellitus?
Specific treatment for gestational diabetes will be determined by your doctor based on:

Your age, overall health, and medical history

Extent of the disease

Your tolerance for specific medications, procedures, or therapies

Expectations for the course of the disease

Your opinion or preference

Treatment for gestational diabetes focuses on keeping blood glucose levels in the normal range. Treatment may include:

Special diet

Exercise

Daily blood glucose monitoring

Insulin injections

Possible complications for the baby
Unlike type 1 diabetes, gestational diabetes generally occurs too late to cause birth defects. Birth defects usually originate sometime during the first trimester (before the 13th week) of pregnancy. The insulin resistance from the contra-insulin hormones produced by the placenta does not usually occur until approximately the 24th week. Women with gestational diabetes mellitus generally have normal blood sugar levels during the critical first trimester.

The complications of GDM are usually manageable and preventable. The key to prevention is careful control of blood sugar levels just as soon as the diagnosis of diabetes is made.

Infants of mothers with gestational diabetes are vulnerable to several chemical imbalances, such as low serum calcium and low serum magnesium levels, but, in general, there are two major problems of gestational diabetes: macrosomia and hypoglycemia:

Macrosomia. Macrosomia refers to a baby who is considerably larger than normal. All of the nutrients the fetus receives come directly from the mother's blood. If the maternal blood has too much glucose, the pancreas of the fetus senses the high glucose levels and produces more insulin in an attempt to use this glucose. The fetus converts the extra glucose to fat. Even when the mother has gestational diabetes, the fetus is able to produce all the insulin it needs. The combination of high blood glucose levels from the mother and high insulin levels in the fetus results in large deposits of fat which causes the fetus to grow excessively large.

Hypoglycemia. Hypoglycemia refers to low blood sugar in the baby immediately after delivery. This problem occurs if the mother's blood sugar levels have been consistently high, causing the fetus to have a high level of insulin in its circulation. After delivery, the baby continues to have a high insulin level, but it no longer has the high level of sugar from its mother, resulting in the newborn's blood sugar level becoming very low. The baby's blood sugar level is checked after birth, and if the level is too low, it may be necessary to give the baby glucose intravenously.

Blood glucose is monitored very closely during labor. Insulin may be given to keep the mother's blood sugar in a normal range to prevent the baby's blood sugar from dropping excessively after delivery.''';
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
      setState(() {});
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  final TextEditingController _age = TextEditingController();
  final TextEditingController _NoofPregnancy = TextEditingController();
  String GestationinpreviousPregnancy = '';
  final TextEditingController _HDL = TextEditingController();
  String FamilyHistory = '';
  String unexplainedprenetalloss = '';
  String LargeChildorBirthDefault = '';
  String PCOS = '';
  final TextEditingController _SysBP = TextEditingController();
  final TextEditingController _DiaBP = TextEditingController();
  final TextEditingController _Hemoglobin = TextEditingController();
  String SedentaryLifestyle = '';
  String Prediabetes = '';
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _age.dispose();
    _NoofPregnancy.dispose();
    _HDL.dispose();
    _SysBP.dispose();
    _DiaBP.dispose();
    _Hemoglobin.dispose();
  }

  void validate() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_age.text.isNotEmpty &&
        _NoofPregnancy.text.isNotEmpty &&
        _Hemoglobin.text.isNotEmpty &&
        GestationinpreviousPregnancy.isNotEmpty &&
        _SysBP.text.isNotEmpty &&
        _HDL.text.isNotEmpty &&
        _DiaBP.text.isNotEmpty &&
        GestationinpreviousPregnancy.isNotEmpty &&
        SedentaryLifestyle.isNotEmpty &&
        Prediabetes.isNotEmpty &&
        PCOS.isNotEmpty &&
        LargeChildorBirthDefault.isNotEmpty &&
        FamilyHistory.isNotEmpty) {
      if (double.parse(_age.text) >= 20 && double.parse(_age.text) <= 45) {
        if (double.parse(_SysBP.text) >= 90 &&
            double.parse(_SysBP.text) <= 180) {
          if (double.parse(_DiaBP.text) >= 60 &&
              double.parse(_DiaBP.text) <= 124) {
            if (double.parse(_NoofPregnancy.text) >= 1 &&
                double.parse(_NoofPregnancy.text) <= 4) {
              if (double.parse(_Hemoglobin.text) >= 8.8 &&
                  double.parse(_Hemoglobin.text) <= 18) {
                if (double.parse(_HDL.text) >= 15 &&
                    double.parse(_HDL.text) <= 70) {
                  gdmfunction();
                } else {
                  showSnackBar(context, "HDL must be below 70 and above 15!");
                }
              } else {
                showSnackBar(
                  context,
                  "Hemoglobin must be below 18 and above 8.8!",
                );
              }
            } else {
              showSnackBar(
                context,
                "No of Pregnancy must be below 4 and above 1!",
              );
            }
          } else {
            showSnackBar(
              context,
              "DiastolicBP must be below 124 and above 60!",
            );
          }
        } else {
          showSnackBar(context, "SystolicBP must be below 180 and above 90!");
        }
      } else {
        showSnackBar(context, "Age must be below 45 and above 20!");
      }
    } else {
      showSnackBar(context, "Enter all Values!!");
    }
  }

  void gdmfunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await Prediction().gdm(
      age: _age.text,
      NoofPregnancy: _NoofPregnancy.text,
      GestationinpreviousPregnancy: GestationinpreviousPregnancy,
      HDL: _HDL.text,
      FamilyHistory: FamilyHistory,
      unexplainedprenetalloss: unexplainedprenetalloss,
      LargeChildorBirthDefault: LargeChildorBirthDefault,
      PCOS: PCOS,
      SysBP: _SysBP.text,
      DiaBP: _DiaBP.text,
      Hemoglobin: _Hemoglobin.text,
      SedentaryLifestyle: SedentaryLifestyle,
      Prediabetes: Prediabetes,
    );
    if (res == "1" || res == "0") {
      setState(() {
        _isLoading = false;
      });
      if (res == '0') {
        _onBasicAlertPressed(context, "No GDM");
      } else {
        _onBasicAlertPressed(context, "You have GDM");
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
      title: "Predicted GDM Status",
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
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
          backgroundColor: whiteColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Gestational\nDiabetes Mellitus',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      'Enter your Observed Data to predict Gestational Diabetes Mellitus',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _age,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Age',
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.format_list_numbered,
                        color: yellowColor,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _NoofPregnancy,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'No of Pregnancy',
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      filled: true,
                      prefixIcon: const Icon(Icons.numbers, color: yellowColor),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _HDL,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'HDL(15-70)',
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.low_priority_rounded,
                        color: yellowColor,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _SysBP,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Systolic BP',
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.medical_services,
                        color: yellowColor,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _DiaBP,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'DiastolicBP',
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.low_priority_rounded,
                        color: yellowColor,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _Hemoglobin,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Hemoglobin(8.8-18)',
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.medical_services,
                        color: yellowColor,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestation in previous Pregnancy ?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: yellowColor,
                          ),
                        ),
                        Column(
                          children: [
                            RadioListTile(
                              title: Text("Yes"),
                              value: "1",
                              groupValue: GestationinpreviousPregnancy,
                              onChanged: (value) {
                                setState(() {
                                  GestationinpreviousPregnancy =
                                      value.toString();
                                });
                              },
                            ),
                            RadioListTile(
                              title: Text("No"),
                              value: "0",
                              groupValue: GestationinpreviousPregnancy,
                              onChanged: (value) {
                                setState(() {
                                  GestationinpreviousPregnancy =
                                      value.toString();
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Family History',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: yellowColor,
                                ),
                              ),
                              Column(
                                children: [
                                  RadioListTile(
                                    title: Text("Yes"),
                                    value: "1",
                                    groupValue: FamilyHistory,
                                    onChanged: (value) {
                                      setState(() {
                                        FamilyHistory = value.toString();
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text("No"),
                                    value: "0",
                                    groupValue: FamilyHistory,
                                    onChanged: (value) {
                                      setState(() {
                                        FamilyHistory = value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'unexplained prenetal loss',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: yellowColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Column(
                                children: [
                                  RadioListTile(
                                    title: Text("Yes"),
                                    value: "1",
                                    groupValue: unexplainedprenetalloss,
                                    onChanged: (value) {
                                      setState(() {
                                        unexplainedprenetalloss =
                                            value.toString();
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text("No"),
                                    value: "0",
                                    groupValue: unexplainedprenetalloss,
                                    onChanged: (value) {
                                      setState(() {
                                        unexplainedprenetalloss =
                                            value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Large Child or Birth Default',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: yellowColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Column(
                                children: [
                                  RadioListTile(
                                    title: Text("Yes"),
                                    value: "1",
                                    groupValue: LargeChildorBirthDefault,
                                    onChanged: (value) {
                                      setState(() {
                                        LargeChildorBirthDefault =
                                            value.toString();
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text("No"),
                                    value: "0",
                                    groupValue: LargeChildorBirthDefault,
                                    onChanged: (value) {
                                      setState(() {
                                        LargeChildorBirthDefault =
                                            value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PCOS',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: yellowColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Column(
                                children: [
                                  RadioListTile(
                                    title: Text("Yes"),
                                    value: "1",
                                    groupValue: PCOS,
                                    onChanged: (value) {
                                      setState(() {
                                        PCOS = value.toString();
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text("No"),
                                    value: "0",
                                    groupValue: PCOS,
                                    onChanged: (value) {
                                      setState(() {
                                        PCOS = value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sedentary Lifestyle',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: yellowColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Column(
                                children: [
                                  RadioListTile(
                                    title: Text("Yes"),
                                    value: "1",
                                    groupValue: SedentaryLifestyle,
                                    onChanged: (value) {
                                      setState(() {
                                        SedentaryLifestyle = value.toString();
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text("No"),
                                    value: "0",
                                    groupValue: SedentaryLifestyle,
                                    onChanged: (value) {
                                      setState(() {
                                        SedentaryLifestyle = value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Prediabetes',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: yellowColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Column(
                                children: [
                                  RadioListTile(
                                    title: Text("Yes"),
                                    value: "1",
                                    groupValue: Prediabetes,
                                    onChanged: (value) {
                                      setState(() {
                                        Prediabetes = value.toString();
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: Text("No"),
                                    value: "0",
                                    groupValue: Prediabetes,
                                    onChanged: (value) {
                                      setState(() {
                                        Prediabetes = value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: whiteColor,
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
                                        color: yellowColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Material(
                                color: yellowColor,
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  splashColor: const Color.fromARGB(
                                    255,
                                    251,
                                    138,
                                    38,
                                  ),
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
                                    child:
                                        !_isLoading
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
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          snapshot
                                                              .data!
                                                              .docs[index]
                                                              .data()['date']
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          ":",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .data()['gdmornot']
                                                                    .toString() ==
                                                                '1'
                                                            ? const Text(
                                                              "You have GDM",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            )
                                                            : const Text(
                                                              "NO GDM",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 18),
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
                                  const SizedBox(height: 20),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ), // Image border
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
                              'Read about GDM',
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
                ],
              ),
            ),
          ),
        );
  }
}
