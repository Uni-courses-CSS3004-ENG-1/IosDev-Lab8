import 'package:flutter/material.dart';

import '../models/product.dart';

/// Local illustrations keep the catalog available without image downloads.
class ProductArt extends StatelessWidget {
  const ProductArt({super.key, required this.product, this.compact = false});

  final Product product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (product.category) {
      'Electronics' => (const Color(0xFFE1E9DD), const Color(0xFF385A45)),
      'Accessories' => (const Color(0xFFF0E1D2), const Color(0xFF876042)),
      'Home' => (const Color(0xFFEEDFD9), const Color(0xFF945E4D)),
      'Sports' => (const Color(0xFFE5E5CF), const Color(0xFF6D713C)),
      _ => (const Color(0xFFDDE6EB), const Color(0xFF466579)),
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(compact ? 18 : 16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: -size * 0.18,
                top: -size * 0.28,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              Transform.rotate(
                angle: -0.12,
                child: Icon(
                  product.avatar,
                  size: size * (compact ? 0.48 : 0.54),
                  color: foreground,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
