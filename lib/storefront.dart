import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'controllers/api_controller.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/store_catalog_service.dart';
import 'widgets/store_widgets.dart';

const _green = Color(0xFF183A34);
const _cream = Color(0xFFF5F0E8);
const _softCard = Color(0xFFF1EBDD);
const _grey = Color(0xFF77736C);

class StorefrontPage extends StatefulWidget {
  const StorefrontPage({super.key});

  @override
  State<StorefrontPage> createState() => _StorefrontPageState();
}

class _StorefrontPageState extends State<StorefrontPage> {
  final _search = TextEditingController();
  final _address = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _apiController = ApiController();
  final _catalogService = const StoreCatalogService();
  final _cart = CartService();
  final _orderService = OrderService();
  final Set<String> _saved = {};
  List<StoreProduct> _apiProducts = [];
  ApiCatalogResponse? _apiResponse;
  StoreTab _tab = StoreTab.home;
  String _category = 'All';
  String _payment = 'Pay on delivery';
  bool _checkout = false;
  bool _catalogLoading = true;
  String? _catalogError;
  String? _order;

  int get _count => _cart.count;
  double get _subtotal => _cart.subtotal;
  double get _delivery => _cart.delivery;
  List<String> get _categories => [
    ...shopCategories,
    ..._apiProducts
        .map((product) => product.category)
        .where((category) => !shopCategories.contains(category))
        .toSet(),
  ];
  List<StoreProduct> get _allProducts => [...shopInventory, ..._apiProducts];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _search.dispose();
    _address.dispose();
    _apiController.dispose();
    super.dispose();
  }

  List<StoreProduct> get _products => _catalogService.filter(
    products: _allProducts,
    query: _search.text,
    category: _category,
    savedIds: _saved,
    savedOnly: _tab == StoreTab.saved,
  );

  Future<void> _loadCatalog() async {
    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });
    try {
      final response = await _apiController.fetchCatalog();
      if (!mounted) return;
      setState(() {
        _apiResponse = response;
        _apiProducts = response.products;
        _catalogLoading = false;
      });
    } on StoreCatalogException catch (error) {
      if (!mounted) return;
      setState(() {
        _catalogError = error.message;
        _catalogLoading = false;
      });
    }
  }

  void _showApiJson() {
    final response = _apiResponse;
    if (response == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .82,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5CEC4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'API JSON response',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text('HTTP ${response.statusCode}'),
                      avatar: const Icon(Icons.check_circle, size: 17),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'GET ${ApiController.endpoint}',
                  style: TextStyle(color: _grey, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202923),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        response.prettyJson,
                        style: const TextStyle(
                          color: Color(0xFFE6F0E7),
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showNav = !_checkout && _order == null;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _page()),
          ],
        ),
      ),
      bottomNavigationBar: showNav ? _bottomNav() : null,
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
    child: Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Menu',
          onPressed: _showMenu,
          icon: const Icon(Icons.menu),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFE8DCCA),
            foregroundColor: _green,
          ),
        ),
        const Spacer(),
        const Text(
          'V SOLES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Shopping bag',
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            setState(() => _tab = StoreTab.bag);
          },
          icon: Badge(
            isLabelVisible: _count > 0,
            label: Text('$_count'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        ),
      ],
    ),
  );

  Widget _page() {
    if (_order case final order?) return _confirmation(order);
    if (_checkout) return _checkoutPage();
    return switch (_tab) {
      StoreTab.home => _home(),
      StoreTab.search => _catalog(),
      StoreTab.bag => _bag(),
      StoreTab.saved => _catalog(savedOnly: true),
    };
  }

  Widget _home() {
    final products = _allProducts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
      children: [
        const Text(
          'Find your next pair.',
          style: TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _searchBox(),
        const SizedBox(height: 14),
        _categoryChips(),
        const SizedBox(height: 18),
        _campaign(),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Browse by style',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _tab = StoreTab.search),
              child: const Text('Shop all'),
            ),
          ],
        ),
        _styleTiles(),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Popular right now',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _tab = StoreTab.search),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                isSaved: _saved.contains(product.id),
                onOpen: () => _productDetails(product),
                onToggleSaved: () => _toggleSaved(product),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _campaign() => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () => _chooseCategory('Running'),
    child: Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SPRING DROP',
                  style: TextStyle(
                    color: Color(0xFFADC8C2),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Fresh steps for\nwarmer days.',
                  maxLines: 2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Shop the running edit  →',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFFDCE8E5), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 140,
            child: CustomPaint(
              painter: _SneakerPainter(color: Color(0xFFF2E7D5)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _styleTiles() {
    const styles = [
      ('Running', Icons.directions_run, Color(0xFFE9E3D7)),
      ('Basketball', Icons.sports_basketball, Color(0xFFE7E4D7)),
      ('Design', Icons.sports_baseball, Color(0xFFE8E1E2)),
      ('Street', Icons.directions_walk, Color(0xFFE8E8E1)),
    ];
    return Row(
      children: [
        for (var i = 0; i < styles.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => _chooseCategory(styles[i].$1),
              child: Container(
                height: 88,
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
                decoration: BoxDecoration(
                  color: _softCard,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: styles[i].$3,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(styles[i].$2, size: 20, color: _green),
                    ),
                    Text(
                      styles[i].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _catalog({bool savedOnly = false}) {
    final products = _products;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  savedOnly ? 'Saved pairs' : 'Find your pair',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!savedOnly && _apiResponse != null)
                TextButton.icon(
                  onPressed: _showApiJson,
                  icon: const Icon(Icons.data_object, size: 18),
                  label: const Text('View JSON'),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: _searchBox(),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: _categoryChips(),
        ),
        const SizedBox(height: 10),
        if (_catalogLoading)
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Text(
              'Loading online catalog…',
              style: TextStyle(color: _grey, fontSize: 12),
            ),
          ),
        if (_catalogError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Online catalog unavailable: $_catalogError',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
                TextButton(onPressed: _loadCatalog, child: const Text('Retry')),
              ],
            ),
          ),
        Expanded(
          child: products.isEmpty
              ? StoreEmptyState(
                  icon: savedOnly ? Icons.favorite_border : Icons.search_off,
                  title: savedOnly ? 'No saved pairs yet' : 'No shoes found',
                  message: savedOnly
                      ? 'Tap a heart to save a pair.'
                      : 'Try another shoe name or style.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => ProductRow(
                    product: products[index],
                    isSaved: _saved.contains(products[index].id),
                    onOpen: () => _productDetails(products[index]),
                    onToggleSaved: () => _toggleSaved(products[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _bag() {
    if (_cart.items.isEmpty) {
      return StoreEmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Your bag is empty',
        message: 'Add a pair you love and it will appear here.',
        action: 'Explore shoes',
        onAction: () => setState(() => _tab = StoreTab.search),
      );
    }
    final items = _cart.items.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 3, 18, 14),
          child: Text(
            'Your bag',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = items[index];
              final item = entry.value;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _softCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ProductArtwork(
                      product: item.product,
                      width: 90,
                      height: 76,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'US size ${_sizeLabel(item.size)}',
                            style: const TextStyle(color: _grey, fontSize: 11),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            formatPeso(item.product.price),
                            style: const TextStyle(
                              color: _green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove one',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _changeQuantity(entry.key, -1),
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      tooltip: 'Add one',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _changeQuantity(entry.key, 1),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _summary(),
      ],
    );
  }

  Widget _summary() => Container(
    padding: const EdgeInsets.fromLTRB(20, 15, 20, 18),
    decoration: const BoxDecoration(
      color: _softCard,
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    child: Column(
      children: [
        _summaryLine('Subtotal', formatPeso(_subtotal, decimals: true)),
        const SizedBox(height: 7),
        _summaryLine(
          'Delivery',
          _delivery == 0 ? 'FREE' : formatPeso(_delivery, decimals: true),
        ),
        const Divider(height: 22),
        _summaryLine(
          'Total',
          formatPeso(_subtotal + _delivery, decimals: true),
          bold: true,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 49,
          child: FilledButton.icon(
            onPressed: () => setState(() => _checkout = true),
            icon: const Icon(Icons.lock_outline),
            label: const Text('Continue to checkout'),
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _checkoutPage() => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 22),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back to bag',
              onPressed: () => setState(() => _checkout = false),
              icon: const Icon(Icons.arrow_back),
            ),
            const Text(
              'Checkout',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _checkoutSection(
          'Delivery details',
          Icons.location_on_outlined,
          TextFormField(
            controller: _address,
            decoration: const InputDecoration(
              labelText: 'Street address',
              hintText: 'Enter your delivery address',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a delivery address'
                : null,
          ),
        ),
        const SizedBox(height: 12),
        _checkoutSection(
          'Payment method',
          Icons.credit_card,
          RadioGroup<String>(
            groupValue: _payment,
            onChanged: (value) {
              if (value != null) setState(() => _payment = value);
            },
            child: Column(
              children: [
                _paymentOption(
                  'Pay on delivery',
                  Icons.local_shipping_outlined,
                ),
                const Divider(height: 1),
                _paymentOption('Card (demo)', Icons.credit_card_outlined),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _checkoutSection(
          'Order total',
          Icons.receipt_long_outlined,
          Column(
            children: [
              _summaryLine(
                'Items ($_count)',
                formatPeso(_subtotal, decimals: true),
              ),
              const SizedBox(height: 7),
              _summaryLine(
                'Delivery',
                _delivery == 0 ? 'FREE' : formatPeso(_delivery, decimals: true),
              ),
              const Divider(height: 22),
              _summaryLine(
                'Total due',
                formatPeso(_subtotal + _delivery, decimals: true),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: _placeOrder,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Place order'),
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Demo checkout: no payment will be charged.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _grey, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _checkoutSection(String title, IconData icon, Widget child) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _softCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 19, color: _green),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );

  Widget _paymentOption(String label, IconData icon) => Material(
    color: Colors.transparent,
    child: RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      value: label,
      title: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      secondary: Icon(icon, color: _green),
      dense: true,
    ),
  );

  Widget _confirmation(String order) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFDDEAE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 40, color: _green),
          ),
          const SizedBox(height: 20),
          const Text(
            'Order placed',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Thanks for choosing V SOLES. Order $order is confirmed.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _grey, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Delivering to ${_address.text.trim()}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: FilledButton(
              onPressed: () => setState(() {
                _order = null;
                _tab = StoreTab.home;
              }),
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue shopping'),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _searchBox() => TextField(
    controller: _search,
    textInputAction: TextInputAction.search,
    onChanged: (_) => setState(() {}),
    onSubmitted: (_) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _tab = StoreTab.search);
    },
    decoration: InputDecoration(
      hintText: 'Search shoes',
      prefixIcon: const Icon(Icons.search, size: 19),
      suffixIcon: _search.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                _search.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close, size: 18),
            ),
      filled: true,
      fillColor: const Color(0xFFF1EAE0),
      contentPadding: const EdgeInsets.symmetric(vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _categoryChips() => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final value = _categories[index];
        return ChoiceChip(
          label: Text(value, style: const TextStyle(fontSize: 11)),
          selected: value == _category,
          onSelected: (_) => _chooseCategory(value),
          backgroundColor: const Color(0xFFF7F3ED),
          selectedColor: const Color(0xFFE8E1D8),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    ),
  );

  Widget _bottomNav() => StoreBottomNav(
    selected: _tab,
    cartCount: _count,
    onSelected: (tab) {
      FocusManager.instance.primaryFocus?.unfocus();
      ScaffoldMessenger.of(context).clearSnackBars();
      setState(() {
        _tab = tab;
        if (_tab == StoreTab.search) _category = 'All';
      });
    },
  );

  Widget _summaryLine(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }

  void _chooseCategory(String value) => setState(() {
    _category = _categories.contains(value) ? value : 'All';
    _tab = StoreTab.search;
  });

  void _toggleSaved(StoreProduct product) => setState(() {
    if (!_saved.add(product.id)) _saved.remove(product.id);
  });

  void _changeQuantity(String key, int delta) =>
      setState(() => _cart.changeQuantity(key, delta));

  void _addToBag(StoreProduct product, double size) {
    setState(() => _cart.add(product, size));
  }

  void _productDetails(StoreProduct product) {
    FocusManager.instance.primaryFocus?.unfocus();
    var size = 8.0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5CEC4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 145,
                  width: double.infinity,
                  child: ProductArtwork(product: product),
                ),
                const SizedBox(height: 13),
                Text(
                  product.category.toUpperCase(),
                  style: const TextStyle(
                    color: _grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      formatPeso(product.price),
                      style: const TextStyle(
                        fontSize: 19,
                        color: _green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(color: _grey, height: 1.35),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Choose your size (US)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final value in [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0])
                      ChoiceChip(
                        label: Text(_sizeLabel(value)),
                        selected: value == size,
                        onSelected: (_) => setSheetState(() => size = value),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: FilledButton.icon(
                    onPressed: () {
                      _addToBag(product, size);
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name}, size ${_sizeLabel(size)}, added to your bag',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text('Add to bag  ·  ${formatPeso(product.price)}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _sizeLabel(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _checkout = false;
      _order = _orderService
          .placeOrder(
            address: _address.text,
            paymentMethod: _payment,
            itemCount: _count,
            total: _subtotal + _delivery,
          )
          .number;
      _cart.clear();
    });
  }

  void _showMenu() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: _cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              'V SOLES',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: const Text('Shop all shoes'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _tab = StoreTab.search);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Saved pairs'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _tab = StoreTab.saved);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Your bag'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _tab = StoreTab.bag);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
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
        ..color = _green
        ..strokeWidth = 3,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SneakerPainter oldDelegate) =>
      oldDelegate.color != color;
}
