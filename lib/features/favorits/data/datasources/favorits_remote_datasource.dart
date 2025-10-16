import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';

class FavoritsRemoteDataSource {
  final ApiService apiService;

  FavoritsRemoteDataSource({required this.apiService});

  Future<List<ProductModel>> fetchFavoritProducts({int page = 1, int pageSize = 20}) async {
    // Mocked response: always return items with is_favorit = true
    await Future.delayed(const Duration(milliseconds: 600));

    const totalItems = 40;
    final start = (page - 1) * pageSize + 1;
    var end = start + pageSize - 1;
    if (end > totalItems) end = totalItems;

    final List<Map<String, dynamic>> list = [];
    for (var i = start; i <= end; i++) {
      list.add({
        'id': i,
        'name': 'Favorit Product #$i',
        'description': 'Loved item #$i by many users',
        'price': (30 + (i % 40)) * 1.0,
        'stock': (i % 7) + 1,
        'sellerId': (i % 4) + 1,
        'is_favorit': true,
      });
    }

    return list.map((e) => ProductModel.fromJson(e)).toList();
  }
}



