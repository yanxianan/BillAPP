import '../../../shared/money/money.dart';
import '../data/default_account.dart';
import '../data/transaction_repository.dart';
import '../domain/category.dart';
import '../domain/transaction.dart';
import '../domain/transaction_type.dart';
import '../domain/transaction_validator.dart';

typedef IdGenerator = String Function();

class CreateTransactionUseCase {
  CreateTransactionUseCase({
    required this.repository,
    IdGenerator? idGenerator,
    DateTime Function()? now,
  }) : _idGenerator = idGenerator ?? _defaultId,
       _now = now ?? DateTime.now;

  final TransactionRepository repository;
  final IdGenerator _idGenerator;
  final DateTime Function() _now;

  Future<Transaction> call({
    required TransactionType type,
    required Money money,
    required Category category,
    String? note,
    DateTime? occurredAt,
  }) async {
    TransactionValidator.validateCreate(
      type: type,
      money: money,
      category: category,
    );

    final now = _now();
    final transaction = Transaction(
      id: _idGenerator(),
      type: type,
      amountMinor: money.minorUnits,
      categoryId: category.id,
      accountId: defaultAccount.id,
      note: _normalizeNote(note),
      occurredAt: occurredAt ?? now,
      createdAt: now,
      updatedAt: now,
    );

    await repository.save(transaction);
    return transaction;
  }

  static String _defaultId() {
    return 'txn_${DateTime.now().microsecondsSinceEpoch}';
  }

  static String? _normalizeNote(String? note) {
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
