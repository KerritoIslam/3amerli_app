import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:amerli_app/core/ui/toast/toast_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/utils/constants/app_language.dart';

/// Error handler utility to display errors as toasts or dialogs
class ErrorHandler {
  static void showError(BuildContext context, dynamic error,
      {bool showDialog = false}) {
    String errorMessage = getErrorMessage(error);

    if (showDialog) {
      _showErrorDialog(context, errorMessage);
    } else {
      ToastService.instance.showToast(
        context,
        errorMessage,
        type: ToastType.error,
      );
    }
  }

  static String getErrorMessage(dynamic error) {
    // Check for ApiException first to show backend message
    if (error is ApiException) {
      var data = error.serverResponse;

      // Debug log - detailed information
      print('ErrorHandler DEBUG:');
      print('  statusCode: ${error.statusCode}');
      print('  data: $data');
      print('  data type: ${data.runtimeType}');
      print('  data is Map: ${data is Map}');
      print('  data is String: ${data is String}');

      // If data is string, try to parse it
      if (data is String) {
        print('  Attempting to parse JSON from String...');
        try {
          var parsed = jsonDecode(data);
          if (parsed is Map || parsed is List) {
            data = parsed;
            print('  Successfully parsed JSON: $data');
          }
        } catch (e) {
          print('  JSON parse failed: $e');
        }
      }

      if (data is Map) {
        print('  Data is Map, checking for message keys...');
        print('  Map keys: ${data.keys.toList()}');

        // Try various common keys for error messages
        final msg = data['message'] ??
            data['Message'] ??
            data['error'] ??
            data['msg'] ??
            data['detail'] ??
            data['description'];

        print('  Extracted msg: $msg (type: ${msg.runtimeType})');

        if (msg != null && msg.toString().trim().isNotEmpty) {
          final result = msg.toString();
          print('  Returning message: $result');
          return result;
        }

        // Handle nested error objects e.g. { "error": { "message": "..." } }
        if (data['error'] is Map) {
          final nestedMsg = data['error']['message'];
          if (nestedMsg != null) {
            print('  Returning nested message: $nestedMsg');
            return nestedMsg.toString();
          }
        }
      }

      // If data is a String (and wasn't valid JSON or was a JSON string), use it if status >= 400
      if (data is String && data.isNotEmpty && (error.statusCode ?? 0) >= 400) {
        print('  Returning plain string data: $data');
        return data;
      }

      print('  No message found in data, using fallback...');

      // Fallback based on status code if no specific message found
      if (error.statusCode == 401) {
        return 'Erreur d\'authentification: Reconnectez-vous';
      }
      if (error.statusCode == 403) return 'Erreur: Accès refusé';
      if (error.statusCode == 404) return 'Erreur: Ressource non trouvée';
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Erreur serveur: Réessayez plus tard';
      }

      return AppLanguage.somethingWentWrongCheckConnection;
    }

    // Network errors
    if (error is SocketException) {
      return AppLanguage.somethingWentWrongCheckConnection;
    }

    if (error is HttpException) {
      return AppLanguage.somethingWentWrongCheckConnection;
    }

    if (error is FormatException) {
      return 'Erreur: Format de données invalide';
    }

    // Check if error message contains common network indicators
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('failed host lookup')) {
      return AppLanguage.somethingWentWrongCheckConnection;
    }

    if (errorString.contains('404')) {
      return 'Erreur: Ressource non trouvée';
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Erreur serveur: Réessayez plus tard';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Erreur d\'authentification: Reconnectez-vous';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Erreur: Accès refusé';
    }

    // Default error message
    return AppLanguage.somethingWentWrongCheckConnection;
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Erreur'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
