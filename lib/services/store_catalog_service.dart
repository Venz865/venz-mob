import 'package:flutter/material.dart';

class StoreProduct {
  const StoreProduct(
    this.id,
    this.name,
    this.category,
    this.price,
    this.color,
    this.description, {
    this.tag,
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final Color color;
  final String description;
  final String? tag;
  final String? imageAsset;
  final String? imageUrl;
}

const shopCategories = [
  'All',
  'Basketball',
  'Running',
  'Training',
  'Trail',
  'Street',
  'Design',
];

const shopInventory = <StoreProduct>[
  StoreProduct(
    'kobe-5-xray',
    'Kobe 5 X-ray',
    'Basketball',
    2000,
    Color(0xFF304FAF),
    'Blue court shoe with responsive cushioning and a lightweight feel.',
    tag: 'BEST SELLER',
    imageAsset: 'assets/products/kobe5_xray.jpg',
  ),
  StoreProduct(
    'kobe-8-what-the',
    'Kobe 8 What the',
    'Basketball',
    2000,
    Color(0xFFDA4B50),
    'Colorful court-ready design with a lightweight, responsive ride.',
    tag: 'NEW',
    imageAsset: 'assets/products/kobe8_what_the.jpg',
  ),
  StoreProduct(
    'studio',
    'Studio Low',
    'Design',
    2800,
    Color(0xFFD5AAA0),
    'A clean low-profile silhouette made for everyday wear.',
  ),
  StoreProduct(
    'tempo',
    'Tempo Flex',
    'Training',
    3400,
    Color(0xFF9BA9B6),
    'Stable support for strength sessions and quick movement.',
  ),
  StoreProduct(
    'city',
    'City Form',
    'Street',
    2500,
    Color(0xFFC5B4A0),
    'Soft cushioning and a versatile shape for long city days.',
  ),
  StoreProduct(
    'summit',
    'Summit XT',
    'Trail',
    4200,
    Color(0xFFAAB69A),
    'Durable traction and breathable support for bigger routes.',
    tag: 'NEW',
  ),
];

class StoreCatalogException implements Exception {
  const StoreCatalogException(this.message);

  final String message;

  @override
  String toString() => message;
}

class StoreCatalogService {
  const StoreCatalogService();

  static const _colors = [
    Color(0xFF304FAF),
    Color(0xFFDA4B50),
    Color(0xFFD5AAA0),
    Color(0xFF9BA9B6),
    Color(0xFFC5B4A0),
    Color(0xFFAAB69A),
  ];

  List<StoreProduct> parseProducts(Object? decoded) {
    final Object? rawProducts = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
        ? decoded['products']
        : null;
    if (rawProducts is! List) {
      throw const StoreCatalogException(
        'The product catalog response did not contain a product array.',
      );
    }

    try {
      return rawProducts
          .map((item) => _productFromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on TypeError {
      throw const StoreCatalogException(
        'The product catalog contains an invalid product.',
      );
    }
  }

  StoreProduct _productFromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['title'];
    final rawCategory = json['category'];
    final price = json['price'];
    if (id is! num && id is! String ||
        name is! String ||
        price is! num ||
        (rawCategory is! String && rawCategory is! Map<String, dynamic>)) {
      throw const StoreCatalogException(
        'The product catalog contains a product with missing required fields.',
      );
    }

    final category = rawCategory is String
        ? _formatCategory(rawCategory)
        : _formatCategory(rawCategory['name'] as String? ?? '');
    final description = json['description'];
    final image = json['thumbnail'] ?? json['image'];
    final colorIndex =
        category.codeUnits.fold<int>(0, (sum, unit) => sum + unit) %
        _colors.length;

    return StoreProduct(
      'api-$id',
      name,
      category,
      price.toDouble(),
      _colors[colorIndex],
      description is String ? description : '',
      imageUrl: image is String && image.isNotEmpty ? image : null,
    );
  }

  String _formatCategory(String category) {
    final words = category.replaceAll('-', ' ').replaceAll('_', ' ').split(' ');
    return words
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  List<StoreProduct> filter({
    required List<StoreProduct> products,
    required String query,
    required String category,
    Set<String> savedIds = const {},
    bool savedOnly = false,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory = category == 'All' || product.category == category;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          '${product.name} ${product.category} ${product.description}'
              .toLowerCase()
              .contains(normalizedQuery);
      final matchesSaved = !savedOnly || savedIds.contains(product.id);
      return matchesCategory && matchesQuery && matchesSaved;
    }).toList();
  }

}

String formatPeso(num value, {bool decimals = false}) {
  final parts = value.toStringAsFixed(decimals ? 2 : 0).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '₱$whole${parts.length > 1 ? '.${parts.last}' : ''}';
}
