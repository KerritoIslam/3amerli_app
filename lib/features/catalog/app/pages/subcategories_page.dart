import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../../domain/entities/category.dart';

class SubcategoriesPage extends StatefulWidget {
  final Category parent;
  const SubcategoriesPage({super.key, required this.parent});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  final Set<int> _selected = <int>{};

  void _toggle(child) {
    setState(() {
      if (_selected.contains(child.id)) _selected.remove(child.id);
      else _selected.add(child.id);
    });
    try {
      final catalogBloc = context.read<CatalogBloc>();
      catalogBloc.add(CatalogLoadEvent(query: child.name));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
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
                    Text(widget.parent.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selected.length == widget.parent.subcategories.length) _selected.clear();
                          else _selected.addAll(widget.parent.subcategories.map((e) => e.id));
                        });
                        final selectedNames = widget.parent.subcategories.where((e) => _selected.contains(e.id)).map((e) => e.name).join(',');
                        try {
                          context.read<CatalogBloc>().add(CatalogLoadEvent(query: selectedNames));
                        } catch (_) {}
                      },
                      child: const Text('Tout'),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: widget.parent.subcategories.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.neutralLight300),
                          itemBuilder: (context, index) {
                            final child = widget.parent.subcategories[index];
                            final selected = _selected.contains(child.id);
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
                              title: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                                child: Text(child.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                              ),
                              trailing: Transform.scale(
                                scale: 0.9,
                                child: Checkbox(
                                  value: selected,
                                  onChanged: (_) => _toggle(child),
                                  shape: const CircleBorder(),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              onTap: () => _toggle(child),
                            );
                          },
                        ),
                      ),

                      // Apply button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              final selectedNames = widget.parent.subcategories.where((e) => _selected.contains(e.id)).map((e) => e.name).join(',');
                              try {
                                context.read<CatalogBloc>().add(CatalogLoadEvent(query: selectedNames));
                              } catch (_) {}
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: const Text('Appliquer les filtres'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
