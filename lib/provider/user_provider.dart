import 'package:flutter/cupertino.dart';
import '../Model/user.dart';
import 'package:Exper/firebase/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final Authmethods _authMethods = Authmethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
