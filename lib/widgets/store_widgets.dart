import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/store_catalog_service.dart';

const _storeGreen = Color(0xFF183A34);
const _storeCream = Color(0xFFF5F0E8);
const _storeCard = Color(0xFFF1EBDD);
const _storeGrey = Color(0xFF77736C);

enum StoreTab { home, search, bag, saved }

class ProductArtwork extends StatelessWidget {
  const ProductArtwork({
    super.key,
    required this.product,
    this.width,
    this.height,
  });

  final StoreProduct product;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: product.color.withValues(alpha: .23),
      borderRadius: BorderRadius.circular(14),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: product.imageUrl != null
          ? Image.network(
              product.imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  CustomPaint(painter: _SneakerPainter(color: product.color)),
            )
          : product.imageAsset == null
          ? CustomPaint(painter: _SneakerPainter(color: product.color))
          : Image.asset(
              product.imageAsset!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  CustomPaint(painter: _SneakerPainter(color: product.color)),
            ),
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.isSaved,
    required this.onOpen,
    required this.onToggleSaved,
  });

  final StoreProduct product;
  final bool isSaved;
  final VoidCallback onOpen;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: Material(
      color: _storeCard,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: ProductArtwork(product: product)),
                    if (product.tag != null)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _storeCream,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            product.tag!,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: _storeGreen,
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        tooltip: isSaved ? 'Unsave pair' : 'Save pair',
                        onPressed: onToggleSaved,
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                product.category.toUpperCase(),
                style: const TextStyle(
                  color: _storeGrey,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatPeso(product.price),
                      style: const TextStyle(
                        color: _storeGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                    child: FilledButton.tonalIcon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ProductRow extends StatelessWidget {
  const ProductRow({
    super.key,
    required this.product,
    required this.isSaved,
    required this.onOpen,
    required this.onToggleSaved,
  });

  final StoreProduct product;
  final bool isSaved;
  final VoidCallback onOpen;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onOpen,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _storeCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ProductArtwork(product: product, width: 94, height: 76),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: _storeGrey,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatPeso(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    color: _storeGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Choose size and add',
            onPressed: onOpen,
            icon: const Icon(Icons.add_shopping_cart, size: 19),
          ),
          IconButton(
            tooltip: isSaved ? 'Unsave pair' : 'Save pair',
            onPressed: onToggleSaved,
            icon: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              size: 19,
            ),
          ),
        ],
      ),
    ),
  );
}

class StoreEmptyState extends StatelessWidget {
  const StoreEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 42, color: _storeGrey),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: _storeGrey),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    ),
  );
}

class StoreBottomNav extends StatelessWidget {
  const StoreBottomNav({
    super.key,
    required this.selected,
    required this.cartCount,
    required this.onSelected,
  });

  final StoreTab selected;
  final int cartCount;
  final ValueChanged<StoreTab> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home', StoreTab.home),
      (Icons.search, 'Search', StoreTab.search),
      (Icons.shopping_bag_outlined, 'Bag', StoreTab.bag),
      (Icons.favorite_border, 'Saved', StoreTab.saved),
    ];
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 4, 18, 10),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: _storeCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final item in items)
              IconButton(
                tooltip: item.$2,
                onPressed: () => onSelected(item.$3),
                style: IconButton.styleFrom(
                  backgroundColor: selected == item.$3
                      ? const Color(0xFFDDEAE7)
                      : Colors.transparent,
                  foregroundColor: selected == item.$3
                      ? _storeGreen
                      : _storeGrey,
                  fixedSize: const Size(46, 46),
                ),
                icon: item.$3 == StoreTab.bag
                    ? Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text('$cartCount'),
                        child: Icon(item.$1),
                      )
                    : Icon(item.$1),
              ),
          ],
        ),
      ),
    );
  }
}

class _SneakerPainter extends CustomPainter {
  const _SneakerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 280, size.height / 140);
    canvas.save();
    canvas.translate(
      (size.width - 280 * scale) / 2,
      (size.height - 140 * scale) / 2,
    );
    canvas.scale(scale);
    final body = Path()
      ..moveTo(20, 80)
      ..cubicTo(42, 42, 82, 18, 140, 28)
      ..cubicTo(180, 34, 214, 52, 246, 70)
      ..cubicTo(262, 79, 268, 90, 260, 100)
      ..lineTo(36, 100)
      ..cubicTo(20, 100, 12, 90, 20, 80)
      ..close();
    final sole = Path()
      ..moveTo(16, 90)
      ..lineTo(248, 90)
      ..cubicTo(258, 90, 264, 96, 261, 102)
      ..lineTo(246, 113)
      ..cubicTo(237, 121, 227, 122, 210, 122)
      ..lineTo(34, 122)
      ..cubicTo(20, 122, 10, 116, 8, 104)
      ..lineTo(8, 96)
      ..cubicTo(8, 92, 10, 90, 16, 90)
      ..close();
    final upper = Path()
      ..moveTo(90, 26)
      ..cubicTo(125, 16, 150, 24, 170, 44)
      ..cubicTo(186, 58, 186, 70, 162, 70)
      ..cubicTo(126, 70, 96, 66, 72, 56)
      ..cubicTo(58, 50, 66, 34, 90, 26)
      ..close();
    canvas.drawPath(body, Paint()..color = color);
    canvas.drawPath(
      sole,
      Paint()
        ..color = const Color(0xFFE7D1A0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawPath(upper, Paint()..color = color.withValues(alpha: .72));
    canvas.drawLine(
      const Offset(82, 76),
      const Offset(198, 76),
      Paint()
        ..color = _storeGreen
        ..strokeWidth = 3,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SneakerPainter oldDelegate) =>
      oldDelegate.color != color;
}
