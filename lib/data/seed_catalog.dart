import 'package:flutter/material.dart';

import '../models/product.dart';

const seedCatalog = <Product>[
  Product(
    id: 'seed-headphones',
    title: 'Wireless Headphones',
    category: 'Electronics',
    rating: 4.8,
    price: 89.99,
    avatar: Icons.headphones,
  ),
  Product(
    id: 'seed-backpack',
    title: 'Everyday Backpack',
    category: 'Accessories',
    rating: 4.6,
    price: 49.99,
    avatar: Icons.backpack,
  ),
  Product(
    id: 'seed-watch',
    title: 'Smart Watch',
    category: 'Electronics',
    rating: 4.7,
    price: 129.99,
    avatar: Icons.watch,
  ),
  Product(
    id: 'seed-coffee',
    title: 'Coffee Mug',
    category: 'Home',
    rating: 4.5,
    price: 14.99,
    avatar: Icons.coffee,
  ),
  Product(
    id: 'seed-shoes',
    title: 'Running Shoes',
    category: 'Sports',
    rating: 4.9,
    price: 79.99,
    avatar: Icons.directions_run,
  ),
  Product(
    id: 'seed-book',
    title: 'Dart Handbook',
    category: 'Books',
    rating: 4.8,
    price: 29.99,
    avatar: Icons.menu_book,
  ),
];
