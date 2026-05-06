import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/presentation/record_screen.dart';

void main() {
  testWidgets('输入金额并选择餐饮后创建最近账单', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecordScreen()));

    await tester.enterText(find.byKey(const Key('amount_input')), '28');
    await tester.tap(find.text('餐饮'));
    await tester.tap(find.text('保存'));
    await tester.pump();

    expect(find.text('28.00'), findsOneWidget);
    expect(find.text('餐饮'), findsWidgets);
  });
}
