import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'bottom_cart_summary.dart';

/// Place this widget near the top of your app's scaffold (above BottomNavigationBar)
/// It listens to CartBloc and shows the summary when there is at least one item.
class CartBottomOverlay extends StatelessWidget {
  final void Function()? onPay;

  const CartBottomOverlay({Key? key, this.onPay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(builder: (context, state) {
      if (state is CartLoaded && state.items.isNotEmpty) {
        return BottomCartSummary(total: state.total, onPay: onPay);
      }
      return const SizedBox.shrink();
    });
  }
}
