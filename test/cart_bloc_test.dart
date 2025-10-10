import 'package:flutter_test/flutter_test.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_event.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_state.dart';
import 'package:amerli_app/features/cart/domain/entities/cart_item.dart';

void main() {
  group('CartBloc', () {
    late CartBloc bloc;

    setUp(() {
      bloc = CartBloc();
    });

    test('initial state is CartInitial', () {
      expect(bloc.state, isA<CartInitial>());
    });

    test('load emits CartLoaded', () async {
      bloc.add(CartLoadEvent());
      await Future.delayed(const Duration(milliseconds: 150));
      expect(bloc.state, isA<CartLoaded>());
    });

    test('add item to empty cart', () async {
      final item = CartItem(productId: 'p1', name: 'Product 1', price: 10.0, quantity: 1);
      bloc.add(CartAddItemEvent(item));
      await Future.delayed(const Duration(milliseconds: 50));
      final state = bloc.state;
      expect(state, isA<CartLoaded>());
      if (state is CartLoaded) {
        expect(state.items.length, 1);
        expect(state.items.first.productId, 'p1');
      }
    });

    test('adding same item increases quantity', () async {
      final item = CartItem(productId: 'p2', name: 'Product 2', price: 5.0, quantity: 1);
      bloc.add(CartAddItemEvent(item));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(CartAddItemEvent(item));
      await Future.delayed(const Duration(milliseconds: 50));
      final state = bloc.state;
      expect(state, isA<CartLoaded>());
      if (state is CartLoaded) {
        expect(state.items.length, 1);
        expect(state.items.first.quantity, 2);
      }
    });

    test('update quantity to 0 removes item', () async {
      final item = CartItem(productId: 'p3', name: 'Product 3', price: 3.0, quantity: 1);
      bloc.add(CartAddItemEvent(item));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(CartUpdateQuantityEvent(productId: 'p3', quantity: 0));
      await Future.delayed(const Duration(milliseconds: 50));
      final state = bloc.state;
      expect(state, isA<CartLoaded>());
      if (state is CartLoaded) {
        expect(state.items.isEmpty, true);
      }
    });

    test('remove item', () async {
      final item = CartItem(productId: 'p4', name: 'Product 4', price: 7.0, quantity: 1);
      bloc.add(CartAddItemEvent(item));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(CartRemoveItemEvent('p4'));
      await Future.delayed(const Duration(milliseconds: 50));
      final state = bloc.state;
      expect(state, isA<CartLoaded>());
      if (state is CartLoaded) {
        expect(state.items.isEmpty, true);
      }
    });

    test('clear cart', () async {
      final item = CartItem(productId: 'p5', name: 'Product 5', price: 2.0, quantity: 1);
      bloc.add(CartAddItemEvent(item));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(CartClearEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      final state = bloc.state;
      expect(state, isA<CartLoaded>());
      if (state is CartLoaded) {
        expect(state.items.isEmpty, true);
      }
    });
  });
}
