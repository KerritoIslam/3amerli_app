import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/admin_brands_repository.dart';

class AdminBrandsRepositoryImpl implements AdminBrandsRepository {
  final ApiService apiService;

  AdminBrandsRepositoryImpl({required this.apiService});

  @override
  Future<List<Brand>> getAllBrands() async {
    try {
      final resp = await apiService.get('/brands');
      if (resp.data is List) {
        return (resp.data as List)
            .map((e) => Brand(
                  id: e['id']?.toString() ?? '',
                  name: e['label']?.toString() ?? e['name']?.toString() ?? '',
                ))
            .toList();
      }
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('[ADMIN BRANDS] Get all brands error: $e');
      rethrow;
    }
  }

  @override
  Future<Brand> getBrandById(String id) async {
    try {
      final resp = await apiService.get('/brands/$id');
      if (resp.data is Map) {
        final data = resp.data as Map;
        return Brand(
          id: data['id']?.toString() ?? id,
          name: data['label']?.toString() ?? data['name']?.toString() ?? '',
        );
      }
      throw Exception('Invalid brand response');
    } catch (e) {
      // ignore: avoid_print
      print('[ADMIN BRANDS] Get brand by id error: $e');
      rethrow;
    }
  }

  @override
  Future<Brand> createBrand(String name) async {
    try {
      final resp = await apiService.post('/brands', data: {'label': name});
      if (resp.data is Map) {
        final data = resp.data as Map;
        return Brand(
          id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: data['label']?.toString() ?? data['name']?.toString() ?? name,
        );
      }
      // If server doesn't return the created brand, return a brand with temporary id
      return Brand(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[ADMIN BRANDS] Create brand error: $e');
      rethrow;
    }
  }

  @override
  Future<Brand> updateBrand(String id, String name) async {
    try {
      final resp = await apiService.put('/brands/$id', data: {'label': name});
      if (resp.data is Map) {
        final data = resp.data as Map;
        return Brand(
          id: data['id']?.toString() ?? id,
          name: data['label']?.toString() ?? data['name']?.toString() ?? name,
        );
      }
      // If server doesn't return the updated brand, return brand with new name
      return Brand(id: id, name: name);
    } catch (e) {
      // ignore: avoid_print
      print('[ADMIN BRANDS] Update brand error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      final resp = await apiService.delete('/brands/$id');
      if (resp.statusCode == null || resp.statusCode! < 200 || resp.statusCode! >= 300) {
        throw Exception('Failed to delete brand: ${resp.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ADMIN BRANDS] Delete brand error: $e');
      rethrow;
    }
  }
}
