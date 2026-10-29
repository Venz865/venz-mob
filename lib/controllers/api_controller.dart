import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/store_catalog_service.dart';

class ApiCatalogResponse {
  const ApiCatalogResponse({
    required this.statusCode,
    required this.rawJson,
    required this.products,
  });

  final int statusCode;
  final Object rawJson;
  final List<StoreProduct> products;

  String get prettyJson => const JsonEncoder.withIndent('  ').convert(rawJson);
}

class ApiController {
  ApiController({http.Client? client, StoreCatalogService? catalogService})
    : _client = client ?? http.Client(),
      _catalogService = catalogService ?? const StoreCatalogService();

  static final endpoint = Uri.https(
    'dummyjson.com',
    '/products/category/mens-shoes',
    {'limit': '30'},
  );

  final http.Client _client;
  final StoreCatalogService _catalogService;

  Future<ApiCatalogResponse> fetchCatalog() async {
    final http.Response response;
    try {
      response = await _client.get(endpoint).timeout(
        const Duration(seconds: 15),
      );
    } on http.ClientException {
      throw const StoreCatalogException(
        'Could not connect to the product catalog.',
      );
    } on TimeoutException {
      throw const StoreCatalogException(
        'The product catalog request timed out.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StoreCatalogException(
        'The product catalog returned HTTP ${response.statusCode}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const StoreCatalogException(
        'The product catalog returned invalid JSON.',
      );
    }

    final products = _catalogService.parseProducts(decoded);
    return ApiCatalogResponse(
      statusCode: response.statusCode,
      rawJson: decoded!,
      products: products,
    );
  }

  void dispose() => _client.close();
}
