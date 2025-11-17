import 'package:amerli_app/features/cart/app/pages/cart.dart';
import 'package:amerli_app/features/orders/presentation/pages/mes_commandes_page.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/widgets/animated_bottom_nav.dart';
import 'package:amerli_app/features/catalog/app/pages/catalog_page.dart';
import 'package:amerli_app/features/profile/app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selected = 0;

  late final List<Widget> _pages;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _pages = [
      const CatalogPage(),
      const CartPage(),
      const MesCommandesPage(),
      const ProfilePage(),
    ];
    _navigatorKeys = List.generate(_pages.length, (_) => GlobalKey<NavigatorState>());
  }

  void _onItemSelected(int idx) {
    setState(() => _selected = idx);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
  NavItem(asset: "assets/icons/home.svg", label: 'Accueil'),
  NavItem(asset: "assets/icons/panier.svg", label: 'Panier'),
  NavItem(asset: "assets/icons/orders.svg", label: 'Commandes'),
  NavItem(asset: "assets/icons/profil.svg", label: 'Profil'),
    ];

    return Scaffold(
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
                    onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => _pages[i]),
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
        ],
      ),
    );
  }
}
