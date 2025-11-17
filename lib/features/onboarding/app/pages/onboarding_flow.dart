import 'package:flutter/material.dart';
import '../../../../core/config/injection.dart' as di;
import '../../../../core/storage/local_storage.dart';
import 'package:amerli_app/utils/constants/app_dimensions.dart';
import '../../../../widgets/custom_tab_bar.dart';
import 'first_intro.dart' as first_intro;
import 'second_intro.dart' as second_intro;
import 'third_intro.dart' as third_intro;
import '../../../auth/app/pages/sign_up_page.dart' as auth_sign_up;

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

/// A small scope that exposes onboarding navigation helpers to descendants.
class OnboardingScope extends InheritedWidget {
  final VoidCallback next;
  final VoidCallback last;

  const OnboardingScope({super.key, required super.child, required this.next, required this.last});

  static OnboardingScope? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<OnboardingScope>();

  @override
  bool updateShouldNotify(covariant OnboardingScope oldWidget) => false;
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int idx) {
    setState(() => _index = idx);
    _controller.animateToPage(idx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _markSeenIfFinal(int idx) async {
    if (idx == 3) {
      try {
        final local = di.sl<LocalStorage>();
        await local.setBool('seen_onboarding', true);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OnboardingScope(
          next: () {
            final nextIndex = (_index + 1).clamp(0, 3);
            _goTo(nextIndex);
            _markSeenIfFinal(nextIndex);
          },
          last: () {
            _goTo(3);
            _markSeenIfFinal(3);
          },
          child: Column(
            children: [
              CustomTabBar(
                // Keep tabs present (tap targets) but remove visible circles by
                // using transparent fixed-height boxes. This preserves spacing
                // and tap behavior while removing the visual dots above the indicator.
                tabs: List.generate(4, (_) => const SizedBox(height: 10)),
                currentIndex: _index,
                onTap: _goTo,
                indicatorColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Theme.of(context).hintColor,
                indicatorHeight: AppDimensions.spacingXS,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (p) {
                    setState(() => _index = p);
                    _markSeenIfFinal(p);
                  },
                  children: [
                    const first_intro.FirstIntro(),
                    const second_intro.SecondIntro(),
                    const third_intro.ThirdIntro(),
                    const auth_sign_up.SignUpPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
