import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exper/firebase/storage_methods.dart';
import 'package:exper/Model/user.dart' as model;
import 'package:shared_preferences/shared_preferences.dart';

class Authmethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
    Uint8List? file,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
        // registering user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String photoUrl;
        if (file != null) {
          photoUrl = await StorageMethods().uploadImageToStorage(
            'profilePics',
            file,
          );
          if (photoUrl == "failed") {
            photoUrl =
                "https://firebasestorage.googleapis.com/v0/b/exper-f7bbf.appspot.com/o/de7834s-6515bd40-8b2c-4dc6-a843-5ac1a95a8b55.jpg?alt=media&token=96c9f834-39d8-428b-84bf-20ffe281d962";
          }
        } else {
          photoUrl =
              "https://firebasestorage.googleapis.com/v0/b/exper-f7bbf.appspot.com/o/de7834s-6515bd40-8b2c-4dc6-a843-5ac1a95a8b55.jpg?alt=media&token=96c9f834-39d8-428b-84bf-20ffe281d962";
        }
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'username': username,
          'email': email,
          "photoUrl": photoUrl,
        });
        res = 'success';
      } else {
        res = "Please enter all the fields";
      }
    } catch (error) {
      return error.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> forgetPassword({required String email}) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty) {
        // reset password
        await _auth.sendPasswordResetEmail(email: email);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> changePassword({
    required String newpassword,
    required String oldpassword,
  }) async {
    String res = "Some error Occurred";
    try {
      if (newpassword.isNotEmpty && oldpassword.isNotEmpty) {
        final user = _auth.currentUser!;
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: oldpassword,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newpassword);
        res = "success";
      } else {
        res = "Please Enter New Password";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> changeemail({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        final user = _auth.currentUser!;
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updateEmail(email);
        await _firestore.collection('users').doc(user.uid).update({
          'email': email,
        });
        res = "success";
      } else {
        res = "Please Enter New Email";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> deleteuser({required String password}) async {
    String res = "Some error Occurred";
    try {
      if (password.isNotEmpty) {
        final user = _auth.currentUser!;
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(cred);

        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        res = "success";
      } else {
        res = "Please Enter Password";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> changename({
    required String newname,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (password.isNotEmpty && newname.isNotEmpty) {
        final user = _auth.currentUser!;
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(cred);
        await _firestore.collection('users').doc(user.uid).update({
          'username': newname,
        });
        res = "success";
      } else {
        res = "Please Enter new Name";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> changephoto({
    Uint8List? file,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (password.isNotEmpty || file != null) {
        final user = _auth.currentUser!;
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(cred);
        String photoUrl;

        photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics',
          file!,
        );

        await _firestore.collection('users').doc(user.uid).update({
          'photoUrl': photoUrl,
        });
        res = "success";
      } else {
        res = "Please Select Image";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
