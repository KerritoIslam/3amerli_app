import 'package:amerli_app/widgets/app_button.dart';
import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:flutter/material.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
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
            Text("Définissez votre localisation Via Saisi Manuelle", style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 24,
                ),
            ),
            SizedBox(height: 16),
            Text(
              "Précisez votre adresse pour recevoir vos livraisons..",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 16,
                  ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 32),
            Text(
              "Rue et numéro *",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.start,
            ),
            AppTextField(),
            SizedBox(height: 16),
            Text(
              "Quartier / Commune",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.start,
            ),
            AppTextField(),
            SizedBox(height: 16),
            Text(
              "Ville",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.start,
            ),
            AppTextField(),
            SizedBox(height: 50),
            AppButton(onPressed: () {}, text: "Valider l’adresse", width: double.infinity, height: 50,),
            SizedBox(height: 60),
            Center(
              child: Text(
                "Utiliser ma position actuelle",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 14,
                      decoration: TextDecoration.underline
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}