import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:Exper/screens/home.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:Exper/Model/Prediction.dart';
import '../widgets/colors.dart';
import '../widgets/utils.dart';

class BasicMaternalHealth extends StatefulWidget {
  const BasicMaternalHealth({super.key});

  @override
  State<BasicMaternalHealth> createState() => _BasicMaternalHealthState();
}

class _BasicMaternalHealthState extends State<BasicMaternalHealth> {
  final TextEditingController _age = TextEditingController();
  final TextEditingController _SBP = TextEditingController();
  final TextEditingController _DBP = TextEditingController();
  final TextEditingController _BS = TextEditingController();
  final TextEditingController _BodyTemp = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _age.dispose();
    _SBP.dispose();
    _DBP.dispose();
    _BS.dispose();
    _BodyTemp.dispose();
  }

  void validate() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_age.text.isNotEmpty &&
        _DBP.text.isNotEmpty &&
        _SBP.text.isNotEmpty &&
        _BS.text.isNotEmpty &&
        _BodyTemp.text.isNotEmpty) {
      if (double.parse(_age.text) >= 10 && double.parse(_age.text) <= 70) {
        if (double.parse(_SBP.text) >= 70 && double.parse(_SBP.text) <= 160) {
          if (double.parse(_DBP.text) >= 49 && double.parse(_DBP.text) <= 100) {
            if (double.parse(_BS.text) >= 6 && double.parse(_BS.text) <= 19) {
              if (double.parse(_BodyTemp.text) >= 98 &&
                  double.parse(_BodyTemp.text) <= 103) {
                maternlhealthfunction();
              } else {
                showSnackBar(
                  context,
                  "BodyTemp  must be below 103 and above 98!",
                );
              }
            } else {
              showSnackBar(context, "BS must be below 19 and above 6!");
            }
          } else {
            showSnackBar(
              context,
              "DiastolicBP must be below 100 and above 49!",
            );
          }
        } else {
          showSnackBar(context, "SystolicBP must be below 160 and above 70!");
        }
      } else {
        showSnackBar(context, "Age must be below 70 and above 10!");
      }
    } else {
      showSnackBar(context, "Enter all Values!!");
    }
  }

  void maternlhealthfunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await Prediction().maternalhealthrisk(
      age: _age.text,
      sbp: _SBP.text,
      dbp: _DBP.text,
      bs: _BS.text,
      bodytemp: _BodyTemp.text,
    );
    if (res == "low risk" || res == "mid risk" || res == "high risk") {
      setState(() {
        _isLoading = false;
      });
      _onBasicAlertPressed(context, res);
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
      title: "Predicted Health",
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
    return Scaffold(
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
                  'Maternal\nHealth Risk',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  'Enter your Observed Data to predict Maternal Risk',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                controller: _SBP,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'SystolicBP',
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
                controller: _DBP,
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
                controller: _BS,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Blood Suger(mmol/L)',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(Icons.bloodtype, color: yellowColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _BodyTemp,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'BodyTemp(F)',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(Icons.thermostat, color: yellowColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                        splashColor: const Color.fromARGB(255, 251, 138, 38),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
