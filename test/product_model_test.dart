import 'package:flutter_test/flutter_test.dart';
import 'package:amerli_app/features/admin/products/data/models/product_model.dart';
import 'package:amerli_app/utils/constants/app_constants.dart';

void main() {
  test('parses price string and resolves mainpicture filename to URL', () {
    final json = {
      'id': 123,
      'name': 'Test product',
      'price': '100',
      'mainpicture': 'image-123.png',
      'images': ['image-123.png']
    };

    final p = ProductModel.fromJson(json);
    expect(p.pricePerLot, 100.0);
    // image resolver will prefix with origin + /files/
    final origin = Uri.parse(AppConstants.apiBaseUrl).origin;
    expect(p.images.isNotEmpty, true);
    expect(p.images.first.startsWith(origin), true);
  });

  test('parses numeric price and http picture as-is', () {
    final json = {
      'id': 2,
      'name': 'Num product',
      'price': 42,
      'images': ['https://example.com/p.jpg']
    };
    final p = ProductModel.fromJson(json);
    expect(p.pricePerLot, 42.0);
    expect(p.images.first, 'https://example.com/p.jpg');
  });
}
