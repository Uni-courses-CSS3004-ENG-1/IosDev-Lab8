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

  for (final grid in [false, true]) {
    testWidgets(
      'Pull refresh works with short ${grid ? 'grid' : 'list'} content',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MyApp());
        if (grid) {
          await tester.tap(find.byTooltip('Show grid'));
          await tester.pumpAndSettle();
        }
        await tester.drag(
          find.byType(grid ? GridView : ListView),
          const Offset(0, 400),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();
        expect(find.text('New Arrival 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Rows dismiss only from right to left', (tester) async {
    await tester.pumpWidget(const MyApp());
    final row = find.byKey(const ValueKey('seed-backpack'));
    await tester.drag(row, const Offset(900, 0));
    await tester.pumpAndSettle();
    expect(row, findsOneWidget);

    await tester.drag(row, const Offset(-900, 0));
    await tester.pumpAndSettle();
    expect(row, findsNothing);
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Undo restores the original index and cannot duplicate an ID', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.drag(
      find.byKey(const ValueKey('seed-backpack')),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.behavior, SnackBarBehavior.floating);
    final undoAgain = snackBar.action!.onPressed;
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    undoAgain();
    await tester.pump();

    final ids = tester
        .widgetList<ProductRow>(find.byType(ProductRow))
        .map((row) => row.product.id)
        .toList();
    expect(ids[1], 'seed-backpack');
    expect(ids.where((id) => id == 'seed-backpack'), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Undo stays safe after refresh and another deletion', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.drag(
      find.byKey(const ValueKey('seed-backpack')),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();
    final refresh = tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pump(const Duration(milliseconds: 1500));
    await refresh;
    await tester.pump();
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    final ids = tester
        .widgetList<ProductRow>(find.byType(ProductRow))
        .map((row) => row.product.id)
        .toList();
    expect(ids.take(3), ['refresh-1', 'seed-backpack', 'seed-headphones']);

    await tester.drag(
      find.byKey(const ValueKey('seed-backpack')),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('seed-headphones')),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('seed-headphones')), findsOneWidget);
    expect(find.byKey(const ValueKey('seed-backpack')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Saved undo clamps its index when the catalog shrinks', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.scrollUntilVisible(find.text('Dart Handbook'), 150);
    await tester.drag(
      find.byKey(const ValueKey('seed-book')),
      const Offset(-900, 0),
    );
    await tester.pumpAndSettle();
    final savedUndo = tester
        .widget<SnackBar>(find.byType(SnackBar))
        .action!
        .onPressed;
    for (var i = 0; i < 5; i++) {
      await tester.drag(find.byType(Dismissible).first, const Offset(-900, 0));
      await tester.pumpAndSettle();
    }
    savedUndo();
    savedUndo();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('seed-book')), findsOneWidget);
    expect(find.byType(ProductRow), findsOneWidget);
    expect(tester.takeException(), isNull);
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
