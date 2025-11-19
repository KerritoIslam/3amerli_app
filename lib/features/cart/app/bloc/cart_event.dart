import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadEvent extends CartEvent {}

class CartAddItemEvent extends CartEvent {
  final CartItem item;

  const CartAddItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class CartRemoveItemEvent extends CartEvent {
  final String productId;

  const CartRemoveItemEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CartUpdateQuantityEvent extends CartEvent {
  final String productId;
  final int quantity;

  const CartUpdateQuantityEvent({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class CartClearEvent extends CartEvent {}
