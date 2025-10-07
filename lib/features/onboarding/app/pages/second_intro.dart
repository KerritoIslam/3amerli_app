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
          padding:  EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
          child: Column(
            children: [
            SizedBox(height: 80,),
            SvgPicture.asset(
              'assets/images/hero/economize_hero.svg',
              width: 250,
              height: 250,
            ),
            SizedBox(height: 40,),
            Text(
              AppLanguage.saveTimeMoney,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            Text(
              AppLanguage.wholesaleBenefits,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 16,
                  ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
               AppButton(onPressed: () => OnboardingScope.of(context)?.last(), text: AppLanguage.skip, backgroundColor: AppColors.hint, width: 150,height: 50,) ,
               AppButton(onPressed: () => OnboardingScope.of(context)?.next(), text: AppLanguage.next, width: 150,height: 50,)
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}