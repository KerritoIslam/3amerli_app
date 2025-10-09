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
      const ProfilePage(),
      const Center(child: Text('Placeholder 1')),
      const Center(child: Text('Placeholder 2')),
    ];
  }

  void _onItemSelected(int idx) {
    setState(() => _selected = idx);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      NavItem(icon: "assets/icons/home.svg", label: 'Accueil'),
      NavItem(icon: "assets/icons/panier.svg", label: 'Panier'),
      NavItem(icon: "assets/icons/favoris.svg", label: 'Favoris'),
      NavItem(icon: "assets/icons/profil.svg", label: 'Profil'),
    ];

    return Scaffold(
      body: SafeArea(child: _pages[_selected]),
      bottomNavigationBar: AnimatedBottomNavBar(
        items: navItems,
        selectedIndex: _selected,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
