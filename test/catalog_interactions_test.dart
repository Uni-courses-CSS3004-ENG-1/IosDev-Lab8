import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_catalog/main.dart';
import 'package:smart_catalog/widgets/product_card.dart';
import 'package:smart_catalog/widgets/product_row.dart';

void main() {
  for (final grid in [false, true]) {
    testWidgets('Refresh prepends after 1500 ms in ${grid ? 'grid' : 'list'}', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      if (grid) {
        await tester.tap(find.byTooltip('Show grid'));
        await tester.pumpAndSettle();
      }

      final indicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      final refresh = indicator.onRefresh();
      await tester.pump(const Duration(milliseconds: 1499));
      expect(find.text('New Arrival 1'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await refresh;
      await tester.pump();

      final firstProduct = grid
          ? tester
                .widgetList<ProductCard>(find.byType(ProductCard))
                .first
                .product
          : tester
                .widgetList<ProductRow>(find.byType(ProductRow))
                .first
                .product;
      expect(firstProduct.id, 'refresh-1');
      expect(find.text('New Arrival 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Pull refresh works when the list is shorter than the viewport', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('New Arrival 1'), findsOneWidget);
  });

  testWidgets('Pending refresh is safe after the screen is disposed', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final refresh = tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1500));
    await refresh;
    expect(tester.takeException(), isNull);
  });
}
