import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/data/default_account.dart';
import 'package:billapp/features/transactions/data/seed_categories.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';

void main() {
  test('提供固定支出和收入分类', () {
    final expense = seedCategories
        .where((category) => category.type == TransactionType.expense)
        .toList();
    final income = seedCategories
        .where((category) => category.type == TransactionType.income)
        .toList();

    expect(expense.map((category) => category.id), contains('food'));
    expect(expense.map((category) => category.name), contains('餐饮'));
    expect(income.map((category) => category.id), contains('salary'));
    expect(income.map((category) => category.name), contains('工资'));
  });

  test('提供默认账户', () {
    expect(defaultAccount.id, 'default_cash');
    expect(defaultAccount.isDefault, isTrue);
  });
}
