import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/data/seed_categories.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';
import 'package:billapp/features/transactions/domain/transaction_validator.dart';
import 'package:billapp/shared/money/money.dart';

void main() {
  test('分类必须匹配账单类型', () {
    final salary = seedCategories.firstWhere(
      (category) => category.id == 'salary',
    );

    expect(
      () => TransactionValidator.validateCreate(
        type: TransactionType.expense,
        money: Money.parseCny('10'),
        category: salary,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
