import 'package:dio/dio.dart';
import 'package:amerli_app/core/dio/api_service.dart';
import '../../domain/entities/brand.dart';
import '../../domain/repositories/admin_brands_repository.dart';

class AdminBrandsRepositoryImpl implements AdminBrandsRepository {
  final ApiService apiService;

  AdminBrandsRepositoryImpl({required this.apiService});

  Never _handleError(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) {
        final msg = data['message'];
        if (msg is List) throw Exception(msg.join('\n'));
        throw Exception(msg.toString());
      }
    }
    throw e;
  }

  @override
  Future<List<Brand>> getAllBrands({int page = 1, int limit = 20}) async {
    try {
      final resp = await apiService
          .get('/brands', queryParameters: {'page': page, 'limit': limit});
      if (resp.data is Map) {
        final data = resp.data as Map;
        final list = (data['data'] as List?) ?? [];
        return list
            .map((e) => Brand(
                  id: e['id']?.toString() ?? '',
                  name: e['label']?.toString() ?? e['name']?.toString() ?? '',
                ))
            .toList();
      }
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
      _handleError(e);
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
      _handleError(e);
    }
  }

  @override
  Future<Brand> createBrand(String name) async {
    try {
      final resp = await apiService.post('/brands', data: {'label': name});
      if (resp.data is Map) {
        final data = resp.data as Map;
        return Brand(
          id: data['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
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
      _handleError(e);
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
      _handleError(e);
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      final resp = await apiService.delete('/brands/$id');
      if (resp.statusCode == null ||
          resp.statusCode! < 200 ||
          resp.statusCode! >= 300) {
        throw Exception('Failed to delete brand: ${resp.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ADMIN BRANDS] Delete brand error: $e');
      _handleError(e);
    }
  }
}
