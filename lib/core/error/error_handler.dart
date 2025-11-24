import 'dart:io';
import 'package:flutter/material.dart';
import 'package:amerli_app/core/ui/toast/toast_service.dart';

import 'package:amerli_app/core/network/api_exception.dart';

/// Error handler utility to display errors as toasts or dialogs
class ErrorHandler {
  static void showError(BuildContext context, dynamic error,
      {bool showDialog = false}) {
    String errorMessage = _getErrorMessage(error);

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

  static String _getErrorMessage(dynamic error) {
    // Check for ApiException first to show backend message
    if (error is ApiException) {
      if (error.serverResponse is Map) {
        final msg =
            error.serverResponse['message'] ?? error.serverResponse['error'];
        if (msg != null) return msg.toString();
      }
      // If no server message, use the exception message if it's not generic
      if (error.message.isNotEmpty && !error.message.contains('ApiException')) {
        return error.message;
      }
    }

    // Network errors
    if (error is SocketException) {
      return 'Erreur réseau: Vérifiez votre connexion internet';
    }

    if (error is HttpException) {
      return 'Erreur réseau: Impossible de se connecter au serveur';
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
      return 'Erreur réseau: Vérifiez votre connexion internet';
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
    return 'Une erreur est survenue';
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
