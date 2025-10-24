import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import '../bloc/brands_bloc.dart';
import '../bloc/brands_event.dart';
import '../bloc/brands_state.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  final Set<int> _selected = <int>{};
  @override
  void initState() {
    super.initState();
    context.read<BrandsBloc>().add(BrandsLoadEvent());
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
                    Text('Marque', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final state = context.read<BrandsBloc>().state;
                        if (state is BrandsLoaded) {
                          setState(() {
                            if (_selected.length == state.items.length) _selected.clear();
                            else _selected.addAll(state.items.map((e) => e.id));
                          });
                          final names = state.items.where((e) => _selected.contains(e.id)).map((e) => e.name).join(',');
                          try {
                            context.read<CatalogBloc>().add(CatalogLoadEvent(query: names));
                          } catch (_) {}
                        }
                      },
                      child: const Text('Tout'),
                    ),
                  ],
                ),
                Expanded(
                  child: BlocBuilder<BrandsBloc, BrandsState>(builder: (context, state) {
                    if (state is BrandsLoading) return const Center(child: CircularProgressIndicator());
                    if (state is BrandsLoaded) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: state.items.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.neutralLight300),
                              itemBuilder: (context, index) {
                                final b = state.items[index];
                                final selected = _selected.contains(b.id);
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                                    child: Text(b.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  ),
                                  trailing: Transform.scale(
                                    scale: 0.9,
                                    child: Checkbox(
                                      value: selected,
                                      onChanged: (_) {
                                        setState(() {
                                          if (selected) _selected.remove(b.id);
                                          else _selected.add(b.id);
                                        });
                                        try {
                                          context.read<CatalogBloc>().add(CatalogLoadEvent(query: b.name));
                                        } catch (_) {}
                                      },
                                      shape: const CircleBorder(),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (selected) _selected.remove(b.id);
                                      else _selected.add(b.id);
                                    });
                                  },
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
                                  final state = context.read<BrandsBloc>().state;
                                  if (state is BrandsLoaded) {
                                    final names = state.items.where((e) => _selected.contains(e.id)).map((e) => e.name).join(',');
                                    try {
                                      context.read<CatalogBloc>().add(CatalogLoadEvent(query: names));
                                    } catch (_) {}
                                  }
                                  Navigator.of(context).pop();
                                },
                                style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                                child: const Text('Appliquer les filtres'),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (state is BrandsError) return Center(child: Text('Error: ${state.message}'));
                    return const SizedBox.shrink();
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
