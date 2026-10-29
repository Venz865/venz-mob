import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vsoles/controllers/api_controller.dart';
import 'package:vsoles/services/store_catalog_service.dart';

void main() {
  test(
    'GET response is decoded into products and retained as displayable JSON',
    () async {
      final controller = ApiController(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url, ApiController.endpoint);
          return http.Response(
            jsonEncode({
              'products': [
                {
                  'id': 42,
                  'title': 'Runner One',
                  'category': 'mens-shoes',
                  'price': 79.5,
                  'description': 'Lightweight running shoe',
                  'thumbnail': 'https://example.com/runner.jpg',
                },
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(controller.dispose);

      final response = await controller.fetchCatalog();

      expect(response.statusCode, 200);
      expect(response.products, hasLength(1));
      expect(response.products.single.id, 'api-42');
      expect(response.products.single.name, 'Runner One');
      expect(response.products.single.category, 'Mens Shoes');
      expect(response.products.single.price, 79.5);
      expect(
        response.products.single.imageUrl,
        'https://example.com/runner.jpg',
      );
      expect(response.prettyJson, contains('"title": "Runner One"'));

      final filteredProducts = const StoreCatalogService().filter(
        products: response.products,
        query: 'lightweight',
        category: 'All',
      );
      expect(filteredProducts, hasLength(1));
    },
  );

  test('non-success HTTP response is surfaced as a catalog error', () async {
    final controller = ApiController(
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );
    addTearDown(controller.dispose);

    await expectLater(
      controller.fetchCatalog(),
      throwsA(
        isA<StoreCatalogException>().having(
          (error) => error.message,
          'message',
          contains('HTTP 503'),
        ),
      ),
    );
  });

  test('invalid JSON response is surfaced as a catalog error', () async {
    final controller = ApiController(
      client: MockClient((_) async => http.Response('not json', 200)),
    );
    addTearDown(controller.dispose);

    await expectLater(
      controller.fetchCatalog(),
      throwsA(isA<StoreCatalogException>()),
    );
  });
}
