import 'package:flutter/material.dart';
import 'package:get/get.dart';

const blueColor = Color(0xFF0085FF);
const orangeColor = Color(0xFFE57164);
const yellowColor = Color(0xffFFA01E);
const whiteColor = Color(0xffffffff);
const darkgreen = Color(0xff17888C);
const darkblue = Color(0xff042944);
const darkpink = Color(0xffD55E56);
const lightorange = Color(0xffEE742B);
const grey = Color(0xffFafafa);
const greydark = Color(0xffECECEC);
const blackgrey = Color(0xff666666);
const lightgreen = Color(0xff42B2A2);
const lightblue = Color(0xff3E7291);
const purple = Color(0xff81178C);
const black = Color.fromARGB(255, 0, 0, 0);

// Simple function to show styled snackbars
void showCustomSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    colorText: Colors.white,
    backgroundColor: Colors.black,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(10),
  );
}
