import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/core/config/injection.dart';
import 'package:amerli_app/widgets/animated_bottom_nav.dart';
import '../../dashboard/app/bloc/dashboard_bloc.dart';
import '../../dashboard/app/pages/dashboard_page.dart';
import '../../orders/app/bloc/admin_orders_bloc.dart';
import '../../orders/app/pages/admin_orders_page.dart';
import '../../products/app/bloc/admin_products_bloc.dart';
import '../../products/app/pages/admin_products_page.dart';
import '../../users/app/bloc/admin_users_bloc.dart';
import '../../users/app/pages/admin_users_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selected = 0;

  late final List<Widget> _pages;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardPage(),
      const AdminOrdersPage(),
      const AdminProductsPage(),
      const AdminUsersPage(),
    ];
    _navigatorKeys = List.generate(_pages.length, (_) => GlobalKey<NavigatorState>());
  }

  void _onItemSelected(int idx) {
    setState(() => _selected = idx);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      NavItem(asset: "assets/icons/home.svg", label: 'Dashboard'),
      NavItem(asset: "assets/icons/orders.svg", label: 'Commandes'),
      NavItem(asset: "assets/icons/panier.svg", label: 'Produits'),
      NavItem(asset: "assets/icons/profil.svg", label: 'Utilisateurs'),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardBloc>()),
        BlocProvider(create: (_) => sl<AdminOrdersBloc>()),
        BlocProvider(create: (_) => sl<AdminProductsBloc>()),
        BlocProvider(create: (_) => sl<AdminUsersBloc>()),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Build an Offstage + Navigator for each tab
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

            // Bottom navigation bar
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
      ),
    );
  }
}
