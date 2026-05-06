import '../domain/transaction.dart';
import 'transaction_repository.dart';

class InMemoryTransactionRepository implements TransactionRepository {
  final List<Transaction> _transactions = [];

  @override
  Future<void> save(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<Transaction>> getRecent({required int limit}) async {
    final active = _transactions
        .where((transaction) => transaction.deletedAt == null)
        .toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return active.take(limit).toList();
  }
}
