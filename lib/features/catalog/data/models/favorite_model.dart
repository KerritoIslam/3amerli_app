import '../../domain/entities/favorite.dart';

class FavoriteModel {
  final int id;
  final int userId;
  final int productId;

  FavoriteModel({required this.id, required this.userId, required this.productId});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: (json['userId'] is num) ? (json['userId'] as num).toInt() : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      productId: (json['productId'] is num) ? (json['productId'] as num).toInt() : int.tryParse(json['productId']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'userId': userId, 'productId': productId};

  Favorite toEntity() => Favorite(id: id, userId: userId, productId: productId);
}
