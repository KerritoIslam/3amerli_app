import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:amerli_app/core/utils/top_toast.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: AppColors.lightPrimary,
              ),
              const SizedBox(height: 24),
              Text(
                AppLanguage.somethingWentWrongCheckConnection,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.lightOnBackground,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final connectivityResult =
                      await Connectivity().checkConnectivity();
                  final hasConnection =
                      connectivityResult != ConnectivityResult.none;

                  if (hasConnection) {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  } else {
                    TopToast.show(
                      context,
                      AppLanguage.somethingWentWrongCheckConnection,
                      isError: true,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppLanguage.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
