import 'package:flutter/foundation.dart';

/// Temporary auth controller for demo purposes. In real app use AuthBloc.
class AuthController extends ChangeNotifier {
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  void logIn() {
    _loggedIn = true;
    notifyListeners();
  }

  void logOut() {
    _loggedIn = false;
    notifyListeners();
  }

  void toggle() {
    _loggedIn = !_loggedIn;
    notifyListeners();
  }
}
