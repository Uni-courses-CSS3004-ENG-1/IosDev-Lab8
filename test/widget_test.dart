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
}
