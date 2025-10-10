import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final int id;
  final int userId;
  final int productId;

  const Favorite({required this.id, required this.userId, required this.productId});

  @override
  List<Object?> get props => [id, userId, productId];
}
