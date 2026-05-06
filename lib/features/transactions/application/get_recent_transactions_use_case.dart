import '../data/transaction_repository.dart';
import '../domain/transaction.dart';

class GetRecentTransactionsUseCase {
  const GetRecentTransactionsUseCase({required this.repository});

  final TransactionRepository repository;

  Future<List<Transaction>> call({required int limit}) {
    return repository.getRecent(limit: limit);
  }
}
