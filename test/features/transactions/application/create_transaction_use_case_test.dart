import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/application/create_transaction_use_case.dart';
import 'package:billapp/features/transactions/application/get_recent_transactions_use_case.dart';
import 'package:billapp/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:billapp/features/transactions/data/seed_categories.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';
import 'package:billapp/shared/money/money.dart';

void main() {
  test('创建账单后可以在最近账单中看到', () async {
    final repository = InMemoryTransactionRepository();
    final create = CreateTransactionUseCase(repository: repository);
    final getRecent = GetRecentTransactionsUseCase(repository: repository);
    final food = seedCategories.firstWhere((category) => category.id == 'food');

    final transaction = await create(
      type: TransactionType.expense,
      money: Money.parseCny('28'),
      category: food,
      note: '午饭',
      occurredAt: DateTime(2026, 5, 6, 12),
    );

    final recent = await getRecent(limit: 10);

    expect(transaction.amountMinor, 2800);
    expect(recent, hasLength(1));
    expect(recent.single.categoryId, 'food');
    expect(recent.single.note, '午饭');
  });
}
