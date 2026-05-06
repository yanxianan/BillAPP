import 'transaction_type.dart';

class Category {
  const Category({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
    required this.sortOrder,
    required this.isSystem,
  });

  final String id;
  final TransactionType type;
  final String name;
  final String icon;
  final int sortOrder;
  final bool isSystem;
}
