import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [productId, name, price, quantity, imageUrl];
}
