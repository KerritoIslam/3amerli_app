import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/features/catalog/data/models/product_model.dart';

class CatalogRemoteDataSource {
  final ApiService apiService;

  CatalogRemoteDataSource({required this.apiService});

  Future<List<ProductModel>> fetchProducts({int page = 1, int pageSize = 50, String? query}) async {
    // Mocked paginated response — generate synthetic products so we can test pagination
    await Future.delayed(const Duration(seconds: 1));

    // Simulate finite total items so pagination ends naturally
    const totalItems = 95;
    final start = (page - 1) * pageSize + 1;
    var end = start + pageSize - 1;
    if (end > totalItems) end = totalItems;
    final List<Map<String, dynamic>> list = [];
    for (var i = start; i <= end; i++) {
      list.add({
        'id': i,
        'name': 'Product #$i',
        'description': 'This is description for product #$i',
        'price': (20 + (i % 50)) * 1.0,
        'stock': (i % 10) + 1,
        'sellerId': (i % 5) + 1,
        // mark every 3rd item as favorite in mock
        'is_favorit': i % 3 == 0,
        // Images: first is the thumbnail used in lists, second is a detail image with transparent background
        'pics': [
          'https://picsum.photos/seed/prod_$i/300/300',
          // example transparent PNG (no-background) — transparent demo image on Wikimedia
          'https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png'
        ],
        'brand': 'Brand #${(i % 10) + 1}',
        // provide a soldBy value (int) for seller mapping
        'soldBy': (i % 7) + 1,
      });
    }

    return list.map((e) => ProductModel.fromJson(e)).toList();
  }
}
