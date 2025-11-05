import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
// Removed unused imports
// import 'categories_page.dart';
// import 'brands_page.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme),
        ),
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              children: [
                  Row(
                    children: [
                      // Back button styled like ProductDetailsPage (smaller)
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/back_arrow.svg',
                            width: 14,
                            height: 14,
                            color: Theme.of(context).colorScheme.onPrimary,
                            placeholderBuilder: (context) => Icon(
                              Icons.arrow_back,
                              size: 14,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Center(
                          child: Text('Filtrer', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                const SizedBox(height: 24),
                ListTile(
                  title: const Text('Categorie'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/filters/categories'),
                ),
                ListTile(
                  title: const Text('Marque'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/filters/brands'),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Appliquer les filtres'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
