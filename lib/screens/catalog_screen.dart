import 'package:flutter/material.dart';

import '../data/seed_catalog.dart';
import '../models/product.dart';
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
        child: _isGrid
            ? GridView.builder(
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
                itemCount: _products.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, thickness: 0.5),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductRow(
                    key: ValueKey(product.id),
                    product: product,
                  );
                },
              ),
      ),
    );
  }
}
