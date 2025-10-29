import 'package:flutter_test/flutter_test.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_bloc.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_event.dart';
import 'package:amerli_app/features/catalog/app/bloc/catalog_state.dart';
import 'package:amerli_app/features/catalog/domain/entities/product.dart';
import 'package:amerli_app/features/catalog/domain/repositories/catalog_repository.dart';

class FakeRepoSuccess implements CatalogRepository {
  final int totalItems;
  FakeRepoSuccess(this.totalItems);

  @override
  Future<List<Product>> getProducts({int page = 1, int pageSize = 50, String? query, List<int>? categoryIds, bool forceRefresh = false}) async {
    // simulate small delay
    await Future.delayed(const Duration(milliseconds: 50));
    final start = (page - 1) * pageSize + 1;
    final end = (start + pageSize - 1).clamp(0, totalItems);
    final items = <Product>[];
    for (var i = start; i <= end && i <= totalItems; i++) {
      items.add(Product(id: i, name: 'P$i', description: 'D$i', price: 1.0 * i, stock: 10, sellerId: (i % 5) + 1));
    }
    return items;
  }
}

class FakeRepoError implements CatalogRepository {
  @override
  Future<List<Product>> getProducts({int page = 1, int pageSize = 50, String? query, List<int>? categoryIds, bool forceRefresh = false}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    throw Exception('network');
  }
}

void main() {
  test('CatalogBloc pagination happy path', () async {
    final repo = FakeRepoSuccess(45); // 45 items
    final bloc = CatalogBloc(repository: repo);

    final states = <CatalogState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(CatalogLoadEvent(pageSize: 20));
    // wait for first page
    await Future.delayed(const Duration(milliseconds: 150));
    expect(states.last, isA<CatalogLoaded>());
    final first = states.last as CatalogLoaded;
    expect(first.products.length, 20);
    expect(first.page, 1);

    // load more
    bloc.add(CatalogLoadEvent(loadMore: true, pageSize: 20));
    await Future.delayed(const Duration(milliseconds: 200));
    expect(states.last, isA<CatalogLoaded>());
    final second = states.last as CatalogLoaded;
    expect(second.products.length, 40);
    expect(second.page, 2);

    // load last page
    bloc.add(CatalogLoadEvent(loadMore: true, pageSize: 20));
    await Future.delayed(const Duration(milliseconds: 200));
    final third = states.last as CatalogLoaded;
    expect(third.products.length, 45);
    expect(third.hasMore, false);

    await sub.cancel();
    await bloc.close();
  });

  test('CatalogBloc error path', () async {
    final repo = FakeRepoError();
    final bloc = CatalogBloc(repository: repo);

    final states = <CatalogState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(CatalogLoadEvent(pageSize: 20));
    await Future.delayed(const Duration(milliseconds: 150));
    expect(states.last, isA<CatalogError>());

    await sub.cancel();
    await bloc.close();
  });
}
