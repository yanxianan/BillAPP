import '../domain/transaction.dart';

abstract interface class TransactionRepository {
  Future<void> save(Transaction transaction);

  Future<List<Transaction>> getRecent({required int limit});
}
