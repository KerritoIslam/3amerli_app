import 'package:amerli_app/features/cart/app/pages/cart.dart';
import 'package:amerli_app/features/orders/presentation/pages/mes_commandes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amerli_app/widgets/animated_bottom_nav.dart';
import 'package:amerli_app/features/catalog/app/pages/catalog_page.dart';
import 'package:amerli_app/features/profile/app/pages/profile_page.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/widgets/draggable_floating_cart_button.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selected;

  late final List<Widget> _pages;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
    _pages = [
      const CatalogPage(),
      const CartPage(),
      const MesCommandesPage(),
      const ProfilePage(),
    ];
    _navigatorKeys =
        List.generate(_pages.length, (_) => GlobalKey<NavigatorState>());
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selected = widget.initialIndex;
      });
    }
  }

  void _onItemSelected(int idx) {
    setState(() => _selected = idx);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) {
        final navItems = [
          NavItem(asset: "assets/icons/home.svg", label: AppLanguage.home),
          NavItem(asset: "assets/icons/panier.svg", label: AppLanguage.cart),
          NavItem(
              asset: "assets/icons/orders.svg", label: AppLanguage.ordersNav),
          NavItem(asset: "assets/icons/profil.svg", label: AppLanguage.profile),
        ];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            final navigator = _navigatorKeys[_selected].currentState;
            if (navigator != null && navigator.canPop()) {
              navigator.pop();
            } else if (_selected != 0) {
              _onItemSelected(0);
            } else {
              // We are at root of tab 0. We should exit.
              SystemNavigator.pop();
            }
          },
          child: Scaffold(
            // Prevent scaffold from resizing when keyboard appears
            resizeToAvoidBottomInset: false,
            // Use a Stack so each tab can host its own Navigator. This allows
            // pushing/replacing routes inside a tab without affecting the
            // global app Navigator or the bottom navigation bar.
            body: Stack(
              children: [
                // Build an Offstage + Navigator for each tab so they preserve
                // their own navigation stacks independently.
                for (int i = 0; i < _pages.length; i++)
                  Positioned.fill(
                    child: Offstage(
                      offstage: _selected != i,
                      child: SafeArea(
                        top: true,
                        bottom: false,
                        child: Navigator(
                          key: _navigatorKeys[i],
                          onGenerateRoute: (settings) =>
                              MaterialPageRoute(builder: (_) => _pages[i]),
                        ),
                      ),
                    ),
                  ),

                // Positioned nav bar at the bottom, inside a SafeArea so it
                // won't overlap system gesture area.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    bottom: true,
                    child: Center(
                      child: AnimatedBottomNavBar(
                        items: navItems,
                        selectedIndex: _selected,
                        onItemSelected: _onItemSelected,
                      ),
                    ),
                  ),
                ),

                // Draggable Cart Button (only on Catalog tab)
                if (_selected == 0)
                  Positioned.fill(
                    child: DraggableFloatingCartButton(
                      onCartTap: () => _onItemSelected(1),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
