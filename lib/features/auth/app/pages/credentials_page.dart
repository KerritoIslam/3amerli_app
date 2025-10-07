import 'package:amerli_app/widgets/app_button.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:flutter/material.dart';

class CredentialsPage extends StatefulWidget {
  const CredentialsPage({super.key});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 64),
            Text("Complétez votre profil", style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 24,
                ),
            ),
            SizedBox(height: 16),
            Text(
              "Ces informations nous permettent de personnaliser vos offres et de valider votre compte.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 16,
                  ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 32),
            Text(
              "Nom de la supérette *",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.start,
            ),
            AppTextField(),
            SizedBox(height: 16),
            Text(
              "Nom et prénom du représentant ",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.start,
            ),
            AppTextField(),
            SizedBox(height: 50),
            AppButton(onPressed: () {}, text: "Valider et continuer", width: double.infinity, height: 50,),
          ],
        ),
      ),
    );
  }
}