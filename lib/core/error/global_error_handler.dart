import 'dart:async';

class GlobalErrorHandler {
  final _errorController = StreamController<String>.broadcast();

  Stream<String> get errorStream => _errorController.stream;

  void reportError(String message) {
    _errorController.add(message);
  }

  void dispose() {
    _errorController.close();
  }
}
