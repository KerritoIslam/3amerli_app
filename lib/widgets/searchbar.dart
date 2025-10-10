import 'package:amerli_app/widgets/app_text_feild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppSearchbar extends StatefulWidget {
  const AppSearchbar({super.key});

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
        onTap: () {},
        child: SvgPicture.asset("assets/icons/filter_icon.svg"),
      ),
      prefixIcon: SvgPicture.asset("assets/icons/search_icon.svg"),
      onChanged: (value) {
        // Handle search input change
      },
    );
  }
}