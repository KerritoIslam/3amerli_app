import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../auth/app/pages/sign_up_page.dart';
import '../../widgets/custom_tab_bar.dart';
import '../../core/storage/local_storage.dart';
import '../../utils/constants/app_text_styles.dart';
import '../../utils/constants/app_dimensions.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _index = 0;
  bool _checked = false;
  bool _seen = false;

  LocalStorage get _storage => GetIt.I<LocalStorage>();

  @override
  void initState() {
    super.initState();
    _loadSeen();
    _controller.addListener(() {
      final page = (_controller.page ?? 0).round();
      if (page != _index) setState(() => _index = page);
    });
  }

  Future<void> _loadSeen() async {
    final val = _storage.getBool('seen_onboarding') ?? false;
    setState(() {
      _seen = val;
      _checked = true;
    });
  }

  Future<void> _markSeen() async {
    await _storage.setBool('seen_onboarding', true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    _controller.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return const SizedBox.shrink();

    // If already seen, show sign up page directly (no tab bar)
    if (_seen) return const SignUpPage();

    final pages = <Widget>[
      _IntroPage(
        title: 'Bienvenue',
        subtitle: 'Découvrez notre application et économisez sur chaque commande.',
        asset: null,
      ),
      _IntroPage(
        title: 'Large choix',
        subtitle: 'Choisissez parmi une large sélection de produits locaux.',
        asset: null,
      ),
      _IntroPage(
        title: 'Livraison rapide',
        subtitle: 'Recevez votre commande rapidement et en toute sécurité.',
        asset: null,
      ),
      // Fourth page is the sign up page
      const SignUpPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) async {
                  setState(() => _index = i);
                  if (i == pages.length - 1) {
                    // mark as seen when user reaches the last page
                    await _markSeen();
                  }
                },
                itemBuilder: (context, i) => pages[i],
              ),
            ),

            // Show custom tab bar for navigation only on onboarding (not on sign up when seen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingL),
              child: CustomTabBar(
                tabs: List.generate(pages.length, (i) => Text('${i + 1}')),
                currentIndex: _index,
                onTap: (i) {
                  _goTo(i);
                },
                indicatorColor: Theme.of(context).colorScheme.onSurface,
                inactiveColor: Theme.of(context).hintColor,
                indicatorHeight: AppDimensions.otpUnderlineThickness,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? asset;

  const _IntroPage({Key? key, required this.title, required this.subtitle, this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (asset != null) ...[
            // placeholder for future asset
            const SizedBox(height: 200),
          ],
          Text(title, style: AppTextStyles.headline1, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(subtitle, style: AppTextStyles.body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
