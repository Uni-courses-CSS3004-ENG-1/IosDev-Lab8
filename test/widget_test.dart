import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_catalog/main.dart';

void main() {
  testWidgets('Catalog shell displays seed products', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Smart Catalog'), findsOneWidget);
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(find.text('Electronics'), findsWidgets);
    expect(find.text('★ 4.8'), findsWidgets);
    expect(find.text('\$89.99'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('List and grid scroll without overflow on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('Dart Handbook'), 150);
    expect(find.text('Dart Handbook'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Show grid'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(find.text('\$89.99'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('Dart Handbook'), 150);
    expect(find.text('Dart Handbook'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Show list'));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
