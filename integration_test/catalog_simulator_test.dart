import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:smart_catalog/data/seed_catalog.dart';
import 'package:smart_catalog/main.dart';
import 'package:smart_catalog/widgets/product_card.dart';
import 'package:smart_catalog/widgets/product_row.dart';

Future<void> pullToRefresh(WidgetTester tester, Type scrollView) async {
  final view = find.byType(scrollView);
  // Scrolling to a title can align the text partway down its grid card.
  // Return to the actual edge before starting the refresh gesture.
  final scrollable = tester.state<ScrollableState>(
    find.descendant(of: view, matching: find.byType(Scrollable)),
  );
  for (var i = 0; i < 20 && scrollable.position.extentBefore > 0; i++) {
    await tester.drag(view, const Offset(0, 200));
    await tester.pumpAndSettle();
  }
  expect(scrollable.position.extentBefore, 0);

  await tester.drag(view, const Offset(0, 400));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simulator catalog layouts and gesture walkthrough', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Wireless Headphones'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Dart Handbook'), 150);
    await tester.pumpAndSettle();
    expect(find.text('Dart Handbook').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Wireless Headphones'), -150);
    await tester.pumpAndSettle();

    await pullToRefresh(tester, ListView);
    expect(
      tester.widgetList<ProductRow>(find.byType(ProductRow)).first.product.id,
      'refresh-1',
    );

    await tester.tap(find.byTooltip('Show grid'));
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<ProductCard>(find.byType(ProductCard)).first.product.id,
      'refresh-1',
    );
    await tester.scrollUntilVisible(find.text('Dart Handbook'), 150);
    await tester.pumpAndSettle();
    expect(find.text('Dart Handbook').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('New Arrival 1'), -150);
    await tester.pumpAndSettle();

    await pullToRefresh(tester, GridView);
    expect(
      tester.widgetList<ProductCard>(find.byType(ProductCard)).first.product.id,
      'refresh-2',
    );

    await tester.tap(find.byTooltip('Show list'));
    await tester.pumpAndSettle();
    final backpack = find.byKey(const ValueKey('seed-backpack'));
    await tester.drag(backpack, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(backpack, findsNothing);
    expect(find.text('Everyday Backpack removed'), findsOneWidget);
    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<ProductRow>(find.byType(ProductRow))
          .map((row) => row.product.id)
          .take(4),
      ['refresh-2', 'refresh-1', 'seed-headphones', 'seed-backpack'],
    );

    for (var i = 0; i < seedCatalog.length + 2; i++) {
      final row = find.ancestor(
        of: find.byType(ProductRow).first,
        matching: find.byType(Dismissible),
      );
      await tester.drag(row, const Offset(-500, 0));
      await tester.pumpAndSettle();
    }
    expect(find.text('Catalog is Empty'), findsOneWidget);
    expect(find.byType(ProductRow), findsNothing);

    await tester.tap(find.byTooltip('Show grid'));
    await tester.pumpAndSettle();
    expect(find.text('Catalog is Empty'), findsOneWidget);
    await tester.tap(find.text('Reset Catalog'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Catalog is Empty'), findsNothing);
    expect(
      tester
          .widgetList<ProductCard>(find.byType(ProductCard))
          .map((card) => card.product.id)
          .take(2),
      seedCatalog.take(2).map((product) => product.id),
    );
    await tester.scrollUntilVisible(find.text('Dart Handbook'), 150);
    await tester.pumpAndSettle();
    expect(find.text('Dart Handbook').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Show list'));
    await tester.pumpAndSettle();
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
