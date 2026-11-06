import 'package:flutter/material.dart';

import '../data/seed_catalog.dart';
import '../models/product.dart';

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
        child: ListView.builder(
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return ListTile(
              key: ValueKey(product.id),
              leading: CircleAvatar(child: Icon(product.avatar)),
              title: Text(product.title),
              subtitle: Text('${product.category} · ★ ${product.rating}'),
              trailing: Text('\$${product.price.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
    );
  }
}
