class Money {
  const Money._(this.minorUnits);

  final int minorUnits;

  static Money parseCny(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) {
      throw const FormatException('金额不能为空');
    }

    final parts = normalized.split('.');
    if (parts.length > 2 || parts.any((part) => part.isEmpty)) {
      throw const FormatException('金额格式不正确');
    }

    final yuan = int.tryParse(parts[0]);
    if (yuan == null || yuan < 0) {
      throw const FormatException('金额格式不正确');
    }

    final fenText = parts.length == 2 ? parts[1] : '';
    if (fenText.length > 2 || int.tryParse(fenText.padRight(1, '0')) == null) {
      throw const FormatException('金额格式不正确');
    }

    final fen = fenText.isEmpty ? 0 : int.parse(fenText.padRight(2, '0'));
    final minorUnits = yuan * 100 + fen;
    if (minorUnits <= 0) {
      throw const FormatException('金额必须大于 0');
    }

    return Money._(minorUnits);
  }

  factory Money.fromMinorUnits(int minorUnits) {
    if (minorUnits <= 0) {
      throw const FormatException('金额必须大于 0');
    }
    return Money._(minorUnits);
  }

  String get displayText {
    final yuan = minorUnits ~/ 100;
    final fen = minorUnits % 100;
    return '$yuan.${fen.toString().padLeft(2, '0')}';
  }
}
