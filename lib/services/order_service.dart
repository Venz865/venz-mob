class StoreOrder {
  const StoreOrder({
    required this.number,
    required this.address,
    required this.paymentMethod,
    required this.itemCount,
    required this.total,
  });

  final String number;
  final String address;
  final String paymentMethod;
  final int itemCount;
  final double total;
}

class OrderService {
  StoreOrder placeOrder({
    required String address,
    required String paymentMethod,
    required int itemCount,
    required double total,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return StoreOrder(
      number: 'VS-${timestamp.substring(timestamp.length - 6)}',
      address: address.trim(),
      paymentMethod: paymentMethod,
      itemCount: itemCount,
      total: total,
    );
  }
}