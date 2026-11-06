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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Smart Catalog'),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Show list' : 'Show grid',
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCatalog,
          child: _products.isEmpty
              ? EmptyCatalog(onReset: _resetCatalog)
              : _isGrid
              ? GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _dismissProduct(product),
                      child: ProductRow(product: product),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
