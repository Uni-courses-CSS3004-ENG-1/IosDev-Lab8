import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.price,
    required this.avatar,
  });

  final String id;
  final String title;
  final String category;
  final double rating;
  final double price;
  final IconData avatar;
}
