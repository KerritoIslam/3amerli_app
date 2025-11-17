import 'package:flutter/foundation.dart' show kDebugMode;

class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DEBUG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[INFO] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // Always log errors, even in release mode
    // ignore: avoid_print
    print('[ERROR] $message');
    if (error != null) {
      // ignore: avoid_print
      print('Error details: $error');
    }
    if (stackTrace != null) {
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
    }
  }
}
