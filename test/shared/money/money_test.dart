import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/shared/money/money.dart';

void main() {
  group('Money', () {
    test('从人民币文本解析为分', () {
      final money = Money.parseCny('12.34');

      expect(money.minorUnits, 1234);
      expect(money.displayText, '12.34');
    });

    test('拒绝空金额、零金额和负数金额', () {
      expect(() => Money.parseCny(''), throwsA(isA<FormatException>()));
      expect(() => Money.parseCny('0'), throwsA(isA<FormatException>()));
      expect(() => Money.parseCny('-1'), throwsA(isA<FormatException>()));
    });
  });
}
