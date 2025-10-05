import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/injection.dart' as di;
import 'utils/theme/app_theme.dart';
import 'features/catalog/app/pages/catalog_page.dart';
import 'features/catalog/app/bloc/catalog_bloc.dart';
import 'features/catalog/app/bloc/catalog_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3amerli',
      theme: AppTheme.light,
      home: BlocProvider(
        create: (_) => di.sl<CatalogBloc>()..add(CatalogLoadEvent()),
        child: const CatalogPage(),
      ),
    );
  }
}
