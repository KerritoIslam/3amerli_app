import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AppSearchbar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  
  const AppSearchbar({super.key, this.onChanged, this.onFilterTap});

  @override
  State<AppSearchbar> createState() => _AppSearchbarState();
}

class _AppSearchbarState extends State<AppSearchbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      
      trailing: InkWell(
        onTap: widget.onFilterTap ?? () => context.push('/filters'),
        child: SvgPicture.asset("assets/icons/filter_icon.svg",color: Theme.of(context).colorScheme.primary),
      ),
      prefixIcon: SvgPicture.asset("assets/icons/search_icon.svg",color: Theme.of(context).colorScheme.primary),
      onChanged: widget.onChanged,
      
    );
  }
}