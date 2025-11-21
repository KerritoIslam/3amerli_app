import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/widgets/app_button.dart';
import 'onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FirstIntro extends StatefulWidget {
  const FirstIntro({super.key});

  @override
  State<FirstIntro> createState() => _FirstIntroState();
}

class _FirstIntroState extends State<FirstIntro>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 80),
              SvgPicture.asset(
                'assets/images/hero/welcom_hero.svg',
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 40),
              SvgPicture.asset(
                'assets/logo/full_logo.svg',
                height: 40,
              ),
              const SizedBox(height: 20),
              Text(
                AppLanguage.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    onPressed: () => OnboardingScope.of(context)?.last(),
                    text: AppLanguage.skip,
                    backgroundColor: AppColors.hint,
                    width: 150,
                  ),
                  AppButton(
                    onPressed: () => OnboardingScope.of(context)?.next(),
                    text: AppLanguage.next,
                    width: 150,
                    height: 50,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}