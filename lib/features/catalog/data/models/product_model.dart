import '../../domain/entities/product.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int? sellerId;
  final int? soldBy;
  final bool isFavorit;
  final List<String> pics;
  final String? brand;

  ProductModel({required this.id, required this.name, required this.description, required this.price, required this.stock, this.sellerId, this.soldBy, this.isFavorit = false, this.pics = const [], this.brand});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Be defensive: ids may be strings in some APIs
    final rawId = json['id'];
    final id = rawId is String ? int.tryParse(rawId) ?? 0 : (rawId as num).toInt();

    return ProductModel(
      id: id,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      stock: (json['stock'] is num) ? (json['stock'] as num).toInt() : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
  sellerId: (json['sellerId'] is num) ? (json['sellerId'] as num).toInt() : (json['soldBy'] is num) ? (json['soldBy'] as num).toInt() : (json['sellerId'] != null ? int.tryParse(json['sellerId'].toString()) : null),
  soldBy: (json['soldBy'] is num) ? (json['soldBy'] as num).toInt() : (json['soldBy'] != null ? int.tryParse(json['soldBy'].toString()) : null),
      isFavorit: json['is_favorit'] == true || json['isFavorit'] == true,
      // `pics` may be provided as a list or the legacy `pic` string may exist.
      pics: (() {
        final p = json['pics'];
        if (p is List) {
          return p.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
        }

        final single = json['pic'] ?? json['image'] ?? json['thumbnail'];
        if (single != null) {
          final s = single.toString();
          return s.isNotEmpty ? [s] : <String>[];
        }

        return <String>[];
      })(),
      // brand could be under several keys depending on the API
      brand: json['brand']?.toString() ?? json['brandName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
  'sellerId': sellerId,
  'soldBy': soldBy,
      'is_favorit': isFavorit,
      'pics': pics,
      'brand': brand,
      };

  Product toEntity() => Product(id: id, name: name, description: description, price: price, stock: stock, sellerId: sellerId, soldBy: soldBy, isFavorit: isFavorit, pics: pics, brand: brand);
}
