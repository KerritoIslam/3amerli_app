import 'dart:convert';

import '../models/brand_model.dart';

class BrandsRemoteDataSource {
  Future<List<BrandModel>> fetchBrands() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sample = '''[
      {"id":1, "name":"Jumbo", "image":"https://picsum.photos/seed/jumbo/100/100"},
      {"id":2, "name":"Skor", "image":"https://picsum.photos/seed/skor/100/100"},
      {"id":3, "name":"Safina", "image":"https://picsum.photos/seed/safina/100/100"},
      {"id":4, "name":"Kenza", "image":"https://picsum.photos/seed/kenza/100/100"}
    ]''';
    final List<dynamic> list = json.decode(sample) as List<dynamic>;
    return list.map((e) => BrandModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
