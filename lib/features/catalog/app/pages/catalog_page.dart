import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/widgets/icon_circle.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import 'package:flutter/material.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bienvenue sur {Logo}", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
            SizedBox(height: 15),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded( // <-- constrain the TextField width
                    child: AppSearchbar(
                      
                    ),
                  ),
                  const SizedBox(width: 10),
                    // Use an InkWell (or GestureDetector) wrapping IconCircle so
                    // the circle's `size` controls the visual radius. IconButton
                    // applies its own constraints/padding which can prevent the
                    // circle from sizing as expected.
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: IconCircle(
                        asset: "assets/icons/notifications.svg",
                        isSelected: false,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 25),
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text("Catégories", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  "Voir tout",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.hint,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.hint,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Item $index"),
                  );
                },
              ),
            ),
          ],

        ),
      ),
    );
  }
}