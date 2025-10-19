import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<CartLoadEvent>(_onLoad);
    on<CartAddItemEvent>(_onAdd);
    on<CartRemoveItemEvent>(_onRemove);
    on<CartUpdateQuantityEvent>(_onUpdate);
    on<CartClearEvent>(_onClear);
  }

  Future<void> _onLoad(CartLoadEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      // no persistence in this initial domain-only feature; start empty
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const CartLoaded());
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void _onAdd(CartAddItemEvent event, Emitter<CartState> emit) {
    final current = state;
    if (current is CartLoaded) {
      final items = List<CartItem>.from(current.items);
      final index = items.indexWhere((i) => i.productId == event.item.productId);
      if (index >= 0) {
        final existing = items[index];
        items[index] = existing.copyWith(quantity: existing.quantity + event.item.quantity);
      } else {
        items.add(event.item);
      }
      emit(CartLoaded(items));
      // debug
      // ignore: avoid_print
      print('CartBloc _onAdd -> items now: ${items.map((e) => '${e.productId}(${e.quantity})').join(', ')}');
    } else {
      emit(CartLoaded([event.item]));
      // debug
      // ignore: avoid_print
      print('CartBloc _onAdd -> items now: ${event.item.productId}(${event.item.quantity})');
    }
  }

  void _onRemove(CartRemoveItemEvent event, Emitter<CartState> emit) {
    final current = state;
    if (current is CartLoaded) {
      final items = current.items.where((i) => i.productId != event.productId).toList();
      emit(CartLoaded(items));
    }
  }

  void _onUpdate(CartUpdateQuantityEvent event, Emitter<CartState> emit) {
    final current = state;
    if (current is CartLoaded) {
      final items = current.items.map((i) {
        if (i.productId == event.productId) {
          return i.copyWith(quantity: event.quantity);
        }
        return i;
      }).where((i) => i.quantity > 0).toList();
      emit(CartLoaded(items));
      // debug
      // ignore: avoid_print
      print('CartBloc _onUpdate -> items now: ${items.map((e) => '${e.productId}(${e.quantity})').join(', ')}');
    
    }
    
  }

  void _onClear(CartClearEvent event, Emitter<CartState> emit) {
    emit(const CartLoaded());
  }
}
