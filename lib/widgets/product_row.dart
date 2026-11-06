import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(product.avatar)),
      title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Chip(
            label: Text(product.category),
            visualDensity: VisualDensity.compact,
          ),
          Text('★ ${product.rating.toStringAsFixed(1)}'),
        ],
      ),
      trailing: Text('\$${product.price.toStringAsFixed(2)}'),
    );
  }
}
