import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_catalog/data/seed_catalog.dart';
import 'package:smart_catalog/main.dart';
import 'package:smart_catalog/widgets/empty_catalog.dart';
import 'package:smart_catalog/widgets/product_card.dart';
import 'package:smart_catalog/widgets/product_row.dart';

Future<void> dismissAll(WidgetTester tester) async {
  for (var i = 0; i < seedCatalog.length; i++) {
    await tester.drag(find.byType(Dismissible).first, const Offset(-900, 0));
    await tester.pumpAndSettle();
  }
}

void main() {
  for (final grid in [false, true]) {
    testWidgets('Empty ${grid ? 'grid' : 'list'} resets the seed catalog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await dismissAll(tester);
      final staleUndo = tester
          .widget<SnackBar>(find.byType(SnackBar))
          .action!
          .onPressed;
      if (grid) {
        await tester.tap(find.byTooltip('Show grid'));
        await tester.pumpAndSettle();
      }
      expect(find.byType(EmptyCatalog), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.text('Catalog is Empty'), findsOneWidget);
      await tester.tap(find.text('Reset Catalog'));
      await tester.pumpAndSettle();
      staleUndo();
      await tester.pump();

      final ids = grid
          ? tester
                .widgetList<ProductCard>(find.byType(ProductCard))
                .map((card) => card.product.id)
          : tester
                .widgetList<ProductRow>(find.byType(ProductRow))
                .map((row) => row.product.id);
      expect(ids, seedCatalog.map((product) => product.id));
      expect(find.byType(EmptyCatalog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);

      if (grid) {
        await tester.tap(find.byTooltip('Show list'));
        await tester.pumpAndSettle();
      }
      await tester.drag(
        find.byKey(const ValueKey('seed-book')),
        const Offset(-900, 0),
      );
      await tester.pumpAndSettle();
      staleUndo();
      await tester.pump();
      expect(find.byKey(const ValueKey('seed-book')), findsNothing);
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('seed-book')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Reset cancels the effect of a pending refresh', (tester) async {
    await tester.pumpWidget(const MyApp());
    await dismissAll(tester);
    final refresh = tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.tap(find.text('Reset Catalog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await refresh;
    expect(find.text('New Arrival 1'), findsNothing);
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pull refresh recovers an empty catalog', (tester) async {
    await tester.pumpWidget(const MyApp());
    await dismissAll(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('New Arrival 1'), findsOneWidget);
    expect(find.byType(EmptyCatalog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
