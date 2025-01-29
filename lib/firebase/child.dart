import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChildOpertions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void updateCid({
    required String cid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cid', cid);
  }

  Future<String> createChild({
    required String nickname,
    required String duedate,
    required String firstday,
  }) async {
    String res = "Some error Occurred";
    try {
      if (nickname.isNotEmpty && duedate.isNotEmpty && firstday.isNotEmpty) {
        final cred = _auth.currentUser!;
        String cid = const Uuid().v1();
        await _firestore
            .collection('child')
            .doc(cred.uid)
            .collection('children')
            .doc(cid)
            .set({
          'cid': cid,
          'dueDate': duedate,
          'firstDay': firstday,
          'nickname': nickname,
        });
        res = 'success';
        updateCid(cid: cid);
      } else {
        res = "Please enter all the fields";
      }
    } catch (error) {
      return error.toString();
    }
    return res;
  }
}
