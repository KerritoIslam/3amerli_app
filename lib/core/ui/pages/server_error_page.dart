import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';

class ServerErrorPage extends StatelessWidget {
  const ServerErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<AppLocale>(
                valueListenable: AppLanguage.localeNotifier,
                builder: (context, locale, _) {
                  return Text(
                   "",// AppLanguage.serverErrorTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<AppLocale>(
                  valueListenable: AppLanguage.localeNotifier,
                  builder: (context, locale, _) {
                    return ElevatedButton(
                      onPressed: () {
                        // Navigate to splash to reinitialize the app
                        context.go('/splash');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(""),// AppLanguage.retryAppInit),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
