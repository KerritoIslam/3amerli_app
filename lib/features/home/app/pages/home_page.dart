import 'package:amerli_app/features/cart/app/pages/cart.dart';
import 'package:amerli_app/features/favorits/app/pages/favorits_page.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/widgets/animated_bottom_nav.dart';
import 'package:amerli_app/features/catalog/app/pages/catalog_page.dart';
import 'package:amerli_app/features/profile/app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selected = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const CatalogPage(),
      const CartPage(),
      const FavoritsPage(),
      const ProfilePage(),
    ];
  }

  void _onItemSelected(int idx) {
    setState(() => _selected = idx);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      NavItem(asset: "assets/icons/home.svg", label: 'Accueil'),
      NavItem(asset: "assets/icons/panier.svg", label: 'Panier'),
      NavItem(asset: "assets/icons/favoris.svg", label: 'Favoris'),
      NavItem(asset: "assets/icons/profil.svg", label: 'Profil'),
    ];

    return Scaffold(
      // Use a Stack so the navigation bar can be positioned on top of
      // page content. Pages will render beneath the nav, avoiding the
      // overflow that occurs when content touches the bar.
      body: Stack(
        children: [
          // Page content - allow it to extend to the full screen so it
          // can appear under the nav bar.
          Positioned.fill(
            child: SafeArea(
              top: true,
              bottom: false, // let content go under the bottom nav
              child: _pages[_selected],
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
