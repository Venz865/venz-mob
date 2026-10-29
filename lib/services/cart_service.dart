import 'store_catalog_service.dart';

class CartLine {
  CartLine(this.product, this.size) : quantity = 1;

  final StoreProduct product;
  final double size;
  int quantity;
}

class CartService {
  final Map<String, CartLine> _items = {};

  Map<String, CartLine> get items => Map.unmodifiable(_items);
  int get count => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  double get delivery => subtotal >= 150 ? 0 : 8;

  void add(StoreProduct product, double size) {
    final key = keyFor(product, size);
    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
    } else {
      _items[key] = CartLine(product, size);
    }
  }

  void changeQuantity(String key, int delta) {
    final item = _items[key];
    if (item == null) return;
    item.quantity += delta;
    if (item.quantity <= 0) _items.remove(key);
  }

  void clear() => _items.clear();

  static String keyFor(StoreProduct product, double size) => '${product.id}:$size';
}