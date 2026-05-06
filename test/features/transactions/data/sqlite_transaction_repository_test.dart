import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/data/sqlite_transaction_repository.dart';
import 'package:billapp/features/transactions/domain/transaction.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';
import 'package:billapp/shared/database/app_database.dart';

void main() {
  test('保存账单后可以从 SQLite 查询最近账单', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = SqliteTransactionRepository(database);

    await repository.save(
      Transaction(
        id: 'txn_1',
        type: TransactionType.expense,
        amountMinor: 2800,
        categoryId: 'food',
        accountId: 'default_cash',
        note: '午饭',
        occurredAt: DateTime(2026, 5, 6, 12),
        createdAt: DateTime(2026, 5, 6, 12),
        updatedAt: DateTime(2026, 5, 6, 12),
      ),
    );

    final recent = await repository.getRecent(limit: 10);

    expect(recent, hasLength(1));
    expect(recent.single.id, 'txn_1');
    expect(recent.single.amountMinor, 2800);
    expect(recent.single.categoryId, 'food');
    expect(recent.single.note, '午饭');
  });
}
