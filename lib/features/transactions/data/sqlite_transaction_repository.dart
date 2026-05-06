import 'package:drift/drift.dart';

import '../../../shared/database/app_database.dart';
import '../domain/transaction.dart';
import '../domain/transaction_type.dart';
import 'transaction_repository.dart';

class SqliteTransactionRepository implements TransactionRepository {
  const SqliteTransactionRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> save(Transaction transaction) async {
    await database.into(database.transactionsTable).insertOnConflictUpdate(
          TransactionsTableCompanion.insert(
            id: transaction.id,
            type: transaction.type.name,
            amountMinor: transaction.amountMinor,
            categoryId: transaction.categoryId,
            accountId: transaction.accountId,
            note: Value(transaction.note),
            occurredAt: transaction.occurredAt,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
            deletedAt: Value(transaction.deletedAt),
          ),
        );
  }

  @override
  Future<List<Transaction>> getRecent({required int limit}) async {
    final rows = await (database.select(database.transactionsTable)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.occurredAt)])
          ..limit(limit))
        .get();

    return rows.map(_toDomain).toList();
  }

  Transaction _toDomain(TransactionsTableData row) {
    return Transaction(
      id: row.id,
      type: TransactionType.values.byName(row.type),
      amountMinor: row.amountMinor,
      categoryId: row.categoryId,
      accountId: row.accountId,
      note: row.note,
      occurredAt: row.occurredAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
