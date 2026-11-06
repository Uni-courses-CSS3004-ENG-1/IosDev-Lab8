import 'package:flutter/material.dart';

import '../data/seed_catalog.dart';
import '../models/product.dart';
import '../widgets/product_row.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<Product> _products = List<Product>.of(seedCatalog);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Smart Catalog'),
      ),
      body: SafeArea(
        child: ListView.separated(
          itemCount: _products.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 0.5),
          itemBuilder: (context, index) {
            final product = _products[index];
            return ProductRow(key: ValueKey(product.id), product: product);
          },
        ),
      ),
    );
  }
}
