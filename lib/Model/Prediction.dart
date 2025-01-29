import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prediction {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> gdm({
    required String age,
    required String NoofPregnancy,
    required String GestationinpreviousPregnancy,
    required String HDL,
    required String FamilyHistory,
    required String unexplainedprenetalloss,
    required String LargeChildorBirthDefault,
    required String PCOS,
    required String SysBP,
    required String DiaBP,
    required String Hemoglobin,
    required String SedentaryLifestyle,
    required String Prediabetes,
  }) async {
    String res = "Some error Occurred";
    if (age.isNotEmpty &&
        NoofPregnancy.isNotEmpty &&
        Hemoglobin.isNotEmpty &&
        unexplainedprenetalloss.isNotEmpty &&
        SysBP.isNotEmpty &&
        HDL.isNotEmpty &&
        DiaBP.isNotEmpty &&
        GestationinpreviousPregnancy.isNotEmpty &&
        SedentaryLifestyle.isNotEmpty &&
        Prediabetes.isNotEmpty &&
        PCOS.isNotEmpty &&
        LargeChildorBirthDefault.isNotEmpty &&
        FamilyHistory.isNotEmpty) {
      var body = [
        {
          "age": age,
          "NoofPregnancy": NoofPregnancy,
          "GestationinpreviousPregnancy": GestationinpreviousPregnancy,
          "HDL": HDL,
          "FamilyHistory": FamilyHistory,
          "unexplainedprenetalloss": unexplainedprenetalloss,
          "LargeChildorBirthDefault": LargeChildorBirthDefault,
          "POCS": PCOS,
          "SysBP": SysBP,
          "DiaBP": DiaBP,
          "Hemoglobin": Hemoglobin,
          "SedentaryLifestyle": SedentaryLifestyle,
          "Prediabetes": Prediabetes,
        },
      ];
      var client = http.Client();
      var uri = Uri.parse(
        "http://ananthusureshas001.pythonanywhere.com/predict",
      );
      Map<String, String> headers = {"Content-type": "application/json"};
      String jsonString = json.encode(body);
      try {
        var resp = await client.post(uri, headers: headers, body: jsonString);
        if (resp.statusCode == 200) {
          print("DATA FETCHED SUCCESSFULLY");
          var result = json.decode(resp.body);
          print(result["prediction"]);

          final cred = _auth.currentUser!;
          var datenow = DateTime.now();
          String date = DateFormat('yyyy-MM-dd').format(datenow).toString();
          final prefs = await SharedPreferences.getInstance();
          var childid = (prefs.getString('cid'))!;
          await _firestore
              .collection('Predictions')
              .doc(childid)
              .collection('GDM')
              .doc(date)
              .set({
                'date': date,
                'gdmornot': result["prediction"],
              }, SetOptions(merge: true));
          await _firestore.collection('Predictions').doc(childid).set({
            'gdmornot': result["prediction"],
          }, SetOptions(merge: true));
          return result["prediction"];
        }
      } catch (e) {
        print("EXCEPTION OCCURRED: $e");
        return e.toString();
      }
    } else {
      res = "Please enter all the fields";
    }
    return res;
  }

  Future<String> maternalhealthrisk({
    required String age,
    required String sbp,
    required String dbp,
    required String bs,
    required String bodytemp,
  }) async {
    String res = "Some error Occurred";
    if (age.isNotEmpty &&
        sbp.isNotEmpty &&
        dbp.isNotEmpty &&
        bs.isNotEmpty &&
        bodytemp.isNotEmpty) {
      var body = [
        {"age": age, "sbp": sbp, "dbp": dbp, "bs": bs, "bodytemp": bodytemp},
      ];

      var client = http.Client();
      var uri = Uri.parse("http://ananthusngce.pythonanywhere.com/predict");
      Map<String, String> headers = {"Content-type": "application/json"};
      String jsonString = json.encode(body);
      try {
        var resp = await client.post(uri, headers: headers, body: jsonString);
        if (resp.statusCode == 200) {
          print("DATA FETCHED SUCCESSFULLY");
          var result = json.decode(resp.body);
          print(result["prediction"]);
          final cred = _auth.currentUser!;
          var datenow = DateTime.now();
          String date = DateFormat('yyyy-MM-dd').format(datenow).toString();
          final prefs = await SharedPreferences.getInstance();
          var childid = (prefs.getString('cid'))!;
          await _firestore
              .collection('Predictions')
              .doc(childid)
              .collection('MaternalRisk')
              .doc(date)
              .set({
                'date': date,
                'age': age,
                'sbp': sbp,
                'dbp': dbp,
                'bs': bs,
                'bodytemp': bodytemp,
                'risk': result["prediction"],
              }, SetOptions(merge: true));
          await _firestore.collection('Predictions').doc(childid).set({
            'MaternalRisk': result["prediction"],
          }, SetOptions(merge: true));
          return result["prediction"];
        }
      } catch (e) {
        print("EXCEPTION OCCURRED: $e");
        return e.toString();
      }
    } else {
      res = "Please enter all the fields";
    }
    return res;
  }

  Future<String> anemiadetection({
    required String Hemoglobin,
    required String MCH,
    required String MCHC,
    required String MCV,
  }) async {
    String res = "Some error Occurred";
    String Gender = "1";
    if (Hemoglobin.isNotEmpty &&
        MCH.isNotEmpty &&
        MCHC.isNotEmpty &&
        MCV.isNotEmpty) {
      var body = [
        {
          "Gender": Gender,
          "Hemoglobin": Hemoglobin,
          "MCH": MCH,
          "MCHC": MCHC,
          "MCV": MCV,
        },
      ];

      var client = http.Client();
      var uri = Uri.parse(
        "http://ananthusureshas001.pythonanywhere.com/predict",
      );
      Map<String, String> headers = {"Content-type": "application/json"};
      String jsonString = json.encode(body);
      try {
        var resp = await client.post(uri, headers: headers, body: jsonString);
        if (resp.statusCode == 200) {
          print("DATA FETCHED SUCCESSFULLY");
          var result = json.decode(resp.body);
          print(result["prediction"]);
          final cred = _auth.currentUser!;
          var datenow = DateTime.now();
          String date = DateFormat('yyyy-MM-dd').format(datenow).toString();
          final prefs = await SharedPreferences.getInstance();
          var childid = (prefs.getString('cid'))!;
          await _firestore
              .collection('Predictions')
              .doc(childid)
              .collection('Anemia')
              .doc(date)
              .set({
                'date': date,
                'Hemoglobin': Hemoglobin,
                'MCH': MCH,
                'MCHC': MCHC,
                'MCV': MCV,
                'anemiaornot': result["prediction"],
              }, SetOptions(merge: true));
          await _firestore.collection('Predictions').doc(childid).set({
            'anemiaornot': result["prediction"],
          }, SetOptions(merge: true));
          return result["prediction"];
        }
      } catch (e) {
        print("EXCEPTION OCCURRED: $e");
        return e.toString();
      }
    } else {
      res = "Please enter all the fields";
    }
    return res;
  }
}
