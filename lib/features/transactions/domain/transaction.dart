import 'transaction_type.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.categoryId,
    required this.accountId,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.deletedAt,
  });

  final String id;
  final TransactionType type;
  final int amountMinor;
  final String categoryId;
  final String accountId;
  final String? note;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
