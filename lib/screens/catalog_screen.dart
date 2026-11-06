import 'package:flutter/material.dart';

import '../data/seed_catalog.dart';
import '../models/product.dart';
import '../widgets/empty_catalog.dart';
import '../widgets/product_card.dart';
import '../widgets/product_row.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<Product> _products = List<Product>.of(seedCatalog);
  bool _isGrid = false;
  int _nextProductId = 1;
  int _catalogVersion = 0;

  void _resetCatalog() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    setState(() {
      _catalogVersion++;
      _products
        ..clear()
        ..addAll(seedCatalog);
    });
  }

  Future<void> _refreshCatalog() async {
    final version = _catalogVersion;
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || version != _catalogVersion) return;

    setState(() {
      final number = _nextProductId++;
      _products.insert(
        0,
        Product(
          id: 'refresh-$number',
          title: 'New Arrival $number',
          category: 'Electronics',
          rating: 4.5,
          price: 39.99,
          avatar: Icons.devices,
        ),
      );
    });
  }

  void _dismissProduct(Product product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) return;
    setState(() => _products.removeAt(index));

    final version = _catalogVersion;
    var restored = false;
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.title} removed'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (!mounted || restored || version != _catalogVersion) return;
            if (_products.any((item) => item.id == product.id)) return;
            restored = true;
            setState(() {
              _products.insert(index.clamp(0, _products.length), product);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.spa_outlined, size: 24),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Smart Catalog',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton.filledTonal(
              tooltip: _isGrid ? 'Show list' : 'Show grid',
              icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGrid = !_isGrid),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Everyday, elevated.',
                    style: TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thoughtful finds for your daily life.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Text(
                        'The collection',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1E9DD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_products.length}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isGrid
                        ? 'Pull down to discover something new'
                        : 'Pull to refresh · Swipe left to remove',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshCatalog,
                child: _products.isEmpty
                    ? EmptyCatalog(onReset: _resetCatalog)
                    : _isGrid
                    ? GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ProductCard(
                            key: ValueKey(product.id),
                            product: product,
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _products.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, thickness: 0.5),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Dismissible(
                            key: ValueKey(product.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: AlignmentDirectional.centerEnd,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => _dismissProduct(product),
                            child: ProductRow(product: product),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
