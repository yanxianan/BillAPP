import '../../../shared/money/money.dart';
import 'category.dart';
import 'transaction_type.dart';

class TransactionValidator {
  const TransactionValidator._();

  static void validateCreate({
    required TransactionType type,
    required Money money,
    required Category category,
  }) {
    if (money.minorUnits <= 0) {
      throw ArgumentError('金额必须大于 0');
    }
    if (category.type != type) {
      throw ArgumentError('分类必须匹配账单类型');
    }
  }
}
