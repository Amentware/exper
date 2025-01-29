import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../widgets/colors.dart';
import '../widgets/utils.dart';

class TimeLine extends StatefulWidget {
  const TimeLine({super.key});

  @override
  State<TimeLine> createState() => _TimeLineState();
}

var child = {};
String cid = "";

class _TimeLineState extends State<TimeLine> {
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
      var childSnap = await FirebaseFirestore.instance
          .collection('child')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('children')
          .doc(cid)
          .get();
      child = childSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
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
                        'Time Line',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text(
                        'Track your pregnancy and View importent days',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 400,
                      padding: const EdgeInsets.symmetric(vertical: 5),
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
                      child: SfCalendar(
                        view: CalendarView.month,
                        showNavigationArrow: true,
                        minDate: DateTime.parse(child['firstDay']),
                        maxDate: DateTime.parse(child['dueDate']),
                        showDatePickerButton: true,
                        cellBorderColor: Colors.transparent,
                        dataSource: _getCalendarDataSource(),
                        monthViewSettings: const MonthViewSettings(
                          showAgenda: true,
                          agendaItemHeight: 50,
                          agendaViewHeight: 70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

DataSource _getCalendarDataSource() {
  List<Appointment> appointments = <Appointment>[];
  DateTime dd = DateTime.parse(child['dueDate']);
  DateTime fd = DateTime.parse(child['firstDay']);
  DateTime firstvisit = DateTime(fd.year, fd.month + 1, fd.day);
  DateTime svisit = DateTime(fd.year, fd.month + 6, fd.day);
  DateTime tvisit = DateTime(fd.year, fd.month + 8, fd.day);
  DateTime fvisit = DateTime(fd.year, fd.month + 9, fd.day);
  DateTime firstscan = DateTime(fd.year, fd.month, fd.day + 70);
  DateTime midscan = DateTime(fd.year, fd.month, fd.day + 133);
  appointments.add(Appointment(
      startTime: dd,
      endTime: dd,
      isAllDay: true,
      subject: 'Due Date',
      color: Colors.red));
  appointments.add(Appointment(
    startTime: fd,
    endTime: fd,
    isAllDay: true,
    subject: 'First Day of the last period',
    color: yellowColor,
  ));
  appointments.add(Appointment(
    startTime: firstvisit,
    endTime: firstvisit,
    isAllDay: true,
    subject: '1st Antenatal Visit',
    color: orangeColor,
  ));
  appointments.add(Appointment(
    startTime: svisit,
    endTime: svisit,
    isAllDay: true,
    subject: '2nd Antenatal Visit',
    color: orangeColor,
  ));
  appointments.add(Appointment(
    startTime: tvisit,
    endTime: tvisit,
    isAllDay: true,
    subject: '3rd Antenatal Visit',
    color: orangeColor,
  ));
  appointments.add(Appointment(
    startTime: fvisit,
    endTime: fvisit,
    isAllDay: true,
    subject: '4th Antenatal Visit',
    color: orangeColor,
  ));
  appointments.add(Appointment(
    startTime: firstscan,
    endTime: firstscan,
    isAllDay: true,
    subject: 'First Scan',
    color: orangeColor,
  ));
  appointments.add(Appointment(
    startTime: midscan,
    endTime: midscan,
    isAllDay: true,
    subject: 'Mid Scan',
    color: orangeColor,
  ));
  return DataSource(appointments);
}
