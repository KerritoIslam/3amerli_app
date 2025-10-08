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
      NavItem(icon: Icons.storefront_outlined, label: 'Catalogue'),
      NavItem(icon: Icons.person_outline, label: 'Profil'),
      NavItem(icon: Icons.list_alt_outlined, label: 'Orders'),
      NavItem(icon: Icons.notifications_none, label: 'Notifications'),
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
