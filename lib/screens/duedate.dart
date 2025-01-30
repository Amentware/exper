import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:exper/firebase/child.dart';

import '../widgets/colors.dart';
import '../widgets/utils.dart';

class dueDate extends StatefulWidget {
  const dueDate({super.key});

  @override
  State<dueDate> createState() => _dueDateState();
}

class _dueDateState extends State<dueDate> {
  final TextEditingController _duedateController = TextEditingController();
  final TextEditingController _lastperiodController = TextEditingController();
  final TextEditingController _nickname = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _duedateController.dispose();
    _lastperiodController.dispose();
    _nickname.dispose();
  }

  void createchildfunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    String res = await ChildOpertions().createChild(
      nickname: _nickname.text,
      duedate: _duedateController.text,
      firstday: _lastperiodController.text,
    );
    if (res == 'success') {
      setState(() {
        _isLoading = false;
      });
      Get.back();
      showSnackBar(context, "New Child Created!");
    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/backgrounds/Android Large - 3.png',
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
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'New Baby',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Enter your Due date to continue ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _nickname,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Nick Name',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.baby_changing_station_sharp,
                          color: lightgreen,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      readOnly: true,
                      controller: _duedateController,
                      onTap: () async {
                        var datenow = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          currentDate: DateTime.now(),
                          context: context,
                          initialDate: DateTime.now(), //get today's date
                          firstDate:
                              DateTime.now(), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(
                            datenow.year,
                            datenow.month + 10,
                            datenow.day,
                          ),
                        );
                        if (pickedDate != null) {
                          final String formattedDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(pickedDate);
                          DateTime firstday = DateTime(
                            datenow.year,
                            pickedDate.month - 9,
                            pickedDate.day - 7,
                          );
                          final String formattedfirstDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(firstday);
                          // format date in required form here we use yyyy-MM-dd that means time is removed

                          setState(() {
                            _duedateController.text =
                                formattedDate; //set foratted date to TextField value.
                            _lastperiodController.text = formattedfirstDate;
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Due Date',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.calendar_month,
                          color: lightgreen,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Or, Calculate Due Date',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Enter your first day of last period ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      readOnly: true,
                      controller: _lastperiodController,
                      onTap: () async {
                        var datenow = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          currentDate: datenow,
                          context: context,
                          initialDate: DateTime(
                            datenow.year,
                            datenow.month,
                            datenow.day - 7,
                          ), //get today's date
                          firstDate: DateTime(
                            datenow.year,
                            datenow.month - 10,
                            datenow.day,
                          ), //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(
                            datenow.year,
                            datenow.month,
                            datenow.day - 7,
                          ),
                        );
                        if (pickedDate != null) {
                          final String formattedDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(pickedDate);
                          // format date in required form here we use yyyy-MM-dd that means time is removed
                          DateTime duedate = DateTime(
                            pickedDate.year,
                            pickedDate.month + 9,
                            pickedDate.day + 7,
                          );
                          final String formatteddueDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(duedate);

                          setState(() {
                            _lastperiodController.text = formattedDate;
                            _duedateController.text = formatteddueDate;
                          });
                        } else {
                          print("Date is not selected");
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'First Day',
                        fillColor: const Color.fromARGB(255, 248, 248, 248),
                        filled: true,
                        prefixIcon: const Icon(
                          Icons.calendar_month_outlined,
                          color: lightgreen,
                        ),
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
                            color: Colors.white,
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
                                    color: lightgreen,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: lightgreen,
                            borderRadius: BorderRadius.circular(50),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: createchildfunction,
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
                                          'Create',
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
