# BillAPP Sprint 001 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 构建 BillAPP v0.1 的第一条可运行闭环：Flutter 项目基础、固定分类、默认账户、账单创建、最近账单列表和基础测试。

**架构：** 使用 Flutter 分层架构。`features/transactions` 承担账单创建和最近账单展示，`shared/money` 负责金额规则，`shared/database` 负责 Drift/SQLite 本地存储。Sprint 001 只实现本地单机能力，不引入登录、云同步和自定义分类。

**技术栈：** Flutter、Dart、Drift、SQLite、flutter_riverpod、flutter_test。

---

## 前置条件

- 本机必须可运行 `flutter --version`。
- 项目根目录是 `D:\Study\codex\BillAPP`。
- 所有文档使用中文。
- 代码标识符使用稳定英文，界面文案使用简体中文。
- 金额以整数“分”为单位存储。

## 文件结构

Sprint 001 创建或修改以下文件：

- 创建：`pubspec.yaml`，定义 Flutter 项目和依赖。
- 创建：`analysis_options.yaml`，启用基础 lint。
- 创建：`lib/main.dart`，App 入口。
- 创建：`lib/app/bill_app.dart`，MaterialApp 和主题。
- 创建：`lib/shared/money/money.dart`，金额值对象。
- 创建：`lib/features/transactions/domain/transaction_type.dart`，账单类型枚举。
- 创建：`lib/features/transactions/domain/category.dart`，分类实体。
- 创建：`lib/features/transactions/domain/account.dart`，账户实体。
- 创建：`lib/features/transactions/domain/transaction.dart`，账单实体。
- 创建：`lib/features/transactions/domain/transaction_validator.dart`，账单创建校验。
- 创建：`lib/features/transactions/data/seed_categories.dart`，固定分类种子数据。
- 创建：`lib/features/transactions/data/default_account.dart`，默认账户。
- 创建：`lib/features/transactions/application/create_transaction_use_case.dart`，创建账单用例。
- 创建：`lib/features/transactions/application/get_recent_transactions_use_case.dart`，最近账单用例。
- 创建：`lib/features/transactions/data/transaction_repository.dart`，账单仓储接口。
- 创建：`lib/features/transactions/data/in_memory_transaction_repository.dart`，Sprint 001 可测试仓储。
- 创建：`lib/features/transactions/presentation/record_screen.dart`，记账首页。
- 创建：`test/shared/money/money_test.dart`。
- 创建：`test/features/transactions/domain/transaction_validator_test.dart`。
- 创建：`test/features/transactions/application/create_transaction_use_case_test.dart`。
- 创建：`test/features/transactions/data/seed_categories_test.dart`。
- 创建：`test/features/transactions/presentation/record_screen_test.dart`。

说明：Sprint 001 先使用内存仓储跑通 TDD 和 UI 闭环。Drift/SQLite 的真实持久化放入 Sprint 001 的后续任务或 Sprint 002，避免在没有 Flutter SDK 和依赖缓存前把数据库生成代码卡死。

## Task 1：初始化 Flutter 项目骨架

**文件：**
- 创建：`pubspec.yaml`
- 创建：`analysis_options.yaml`
- 创建：`lib/main.dart`
- 创建：`lib/app/bill_app.dart`

- [ ] **Step 1：确认 Flutter 可用**

运行：

```powershell
flutter --version
```

预期：输出 Flutter 版本号。

- [ ] **Step 2：写最小 App 入口**

创建 `pubspec.yaml`：

```yaml
name: billapp
description: 极简快速记账 App。
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  intl: ^0.19.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

创建 `analysis_options.yaml`：

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
```

创建 `lib/main.dart`：

```dart
import 'package:flutter/material.dart';

import 'app/bill_app.dart';

void main() {
  runApp(const BillApp());
}
```

创建 `lib/app/bill_app.dart`：

```dart
import 'package:flutter/material.dart';

class BillApp extends StatelessWidget {
  const BillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BillAPP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('BillAPP')),
      ),
    );
  }
}
```

- [ ] **Step 3：运行基础检查**

运行：

```powershell
flutter pub get
flutter test
```

预期：依赖安装成功，测试命令成功完成。

- [ ] **Step 4：提交**

```powershell
git add pubspec.yaml analysis_options.yaml lib/main.dart lib/app/bill_app.dart
git commit -m "chore: initialize Flutter app"
```

## Task 2：金额值对象

**文件：**
- 创建：`test/shared/money/money_test.dart`
- 创建：`lib/shared/money/money.dart`

- [ ] **Step 1：写失败测试**

创建 `test/shared/money/money_test.dart`：

```dart
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
```

- [ ] **Step 2：验证测试失败**

运行：

```powershell
flutter test test/shared/money/money_test.dart
```

预期：失败，原因是 `Money` 文件或类型不存在。

- [ ] **Step 3：实现最小代码**

创建 `lib/shared/money/money.dart`：

```dart
class Money {
  const Money._(this.minorUnits);

  final int minorUnits;

  static Money parseCny(String input) {
    final normalized = input.trim();
    if (normalized.isEmpty) {
      throw const FormatException('金额不能为空');
    }

    final value = double.tryParse(normalized);
    if (value == null || value <= 0) {
      throw const FormatException('金额必须大于 0');
    }

    final minorUnits = (value * 100).round();
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
```

- [ ] **Step 4：验证测试通过**

运行：

```powershell
flutter test test/shared/money/money_test.dart
```

预期：通过。

- [ ] **Step 5：提交**

```powershell
git add lib/shared/money/money.dart test/shared/money/money_test.dart
git commit -m "feat: add CNY money value object"
```

## Task 3：固定分类和默认账户

**文件：**
- 创建：`test/features/transactions/data/seed_categories_test.dart`
- 创建：`lib/features/transactions/domain/transaction_type.dart`
- 创建：`lib/features/transactions/domain/category.dart`
- 创建：`lib/features/transactions/domain/account.dart`
- 创建：`lib/features/transactions/data/seed_categories.dart`
- 创建：`lib/features/transactions/data/default_account.dart`

- [ ] **Step 1：写失败测试**

创建 `test/features/transactions/data/seed_categories_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/data/default_account.dart';
import 'package:billapp/features/transactions/data/seed_categories.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';

void main() {
  test('提供固定支出和收入分类', () {
    final expense = seedCategories
        .where((category) => category.type == TransactionType.expense)
        .toList();
    final income = seedCategories
        .where((category) => category.type == TransactionType.income)
        .toList();

    expect(expense.map((category) => category.id), contains('food'));
    expect(expense.map((category) => category.name), contains('餐饮'));
    expect(income.map((category) => category.id), contains('salary'));
    expect(income.map((category) => category.name), contains('工资'));
  });

  test('提供默认账户', () {
    expect(defaultAccount.id, 'default_cash');
    expect(defaultAccount.isDefault, isTrue);
  });
}
```

- [ ] **Step 2：验证测试失败**

运行：

```powershell
flutter test test/features/transactions/data/seed_categories_test.dart
```

预期：失败，原因是分类和账户文件不存在。

- [ ] **Step 3：实现最小代码**

创建 `lib/features/transactions/domain/transaction_type.dart`：

```dart
enum TransactionType { expense, income }
```

创建 `lib/features/transactions/domain/category.dart`：

```dart
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
```

创建 `lib/features/transactions/domain/account.dart`：

```dart
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
  });

  final String id;
  final String name;
  final String type;
  final bool isDefault;
}
```

创建 `lib/features/transactions/data/seed_categories.dart`：

```dart
import '../domain/category.dart';
import '../domain/transaction_type.dart';

const seedCategories = <Category>[
  Category(id: 'food', type: TransactionType.expense, name: '餐饮', icon: 'restaurant', sortOrder: 10, isSystem: true),
  Category(id: 'transport', type: TransactionType.expense, name: '交通', icon: 'directions_bus', sortOrder: 20, isSystem: true),
  Category(id: 'shopping', type: TransactionType.expense, name: '购物', icon: 'shopping_bag', sortOrder: 30, isSystem: true),
  Category(id: 'entertainment', type: TransactionType.expense, name: '娱乐', icon: 'sports_esports', sortOrder: 40, isSystem: true),
  Category(id: 'housing', type: TransactionType.expense, name: '住房', icon: 'home', sortOrder: 50, isSystem: true),
  Category(id: 'medical', type: TransactionType.expense, name: '医疗', icon: 'local_hospital', sortOrder: 60, isSystem: true),
  Category(id: 'education', type: TransactionType.expense, name: '学习', icon: 'school', sortOrder: 70, isSystem: true),
  Category(id: 'other_expense', type: TransactionType.expense, name: '其他', icon: 'more_horiz', sortOrder: 80, isSystem: true),
  Category(id: 'salary', type: TransactionType.income, name: '工资', icon: 'payments', sortOrder: 10, isSystem: true),
  Category(id: 'part_time', type: TransactionType.income, name: '兼职', icon: 'work', sortOrder: 20, isSystem: true),
  Category(id: 'investment', type: TransactionType.income, name: '理财', icon: 'trending_up', sortOrder: 30, isSystem: true),
  Category(id: 'gift', type: TransactionType.income, name: '礼金', icon: 'redeem', sortOrder: 40, isSystem: true),
  Category(id: 'other_income', type: TransactionType.income, name: '其他', icon: 'more_horiz', sortOrder: 50, isSystem: true),
];
```

创建 `lib/features/transactions/data/default_account.dart`：

```dart
import '../domain/account.dart';

const defaultAccount = Account(
  id: 'default_cash',
  name: '默认账户',
  type: 'cash',
  isDefault: true,
);
```

- [ ] **Step 4：验证测试通过**

运行：

```powershell
flutter test test/features/transactions/data/seed_categories_test.dart
```

预期：通过。

- [ ] **Step 5：提交**

```powershell
git add lib/features/transactions test/features/transactions/data/seed_categories_test.dart
git commit -m "feat: add system categories and default account"
```

## Task 4：账单创建用例

**文件：**
- 创建：`test/features/transactions/domain/transaction_validator_test.dart`
- 创建：`test/features/transactions/application/create_transaction_use_case_test.dart`
- 创建：`lib/features/transactions/domain/transaction.dart`
- 创建：`lib/features/transactions/domain/transaction_validator.dart`
- 创建：`lib/features/transactions/data/transaction_repository.dart`
- 创建：`lib/features/transactions/data/in_memory_transaction_repository.dart`
- 创建：`lib/features/transactions/application/create_transaction_use_case.dart`
- 创建：`lib/features/transactions/application/get_recent_transactions_use_case.dart`

- [ ] **Step 1：写失败测试**

创建 `test/features/transactions/domain/transaction_validator_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/data/seed_categories.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';
import 'package:billapp/features/transactions/domain/transaction_validator.dart';
import 'package:billapp/shared/money/money.dart';

void main() {
  test('分类必须匹配账单类型', () {
    final salary = seedCategories.firstWhere((category) => category.id == 'salary');

    expect(
      () => TransactionValidator.validateCreate(
        type: TransactionType.expense,
        money: Money.parseCny('10'),
        category: salary,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
```

创建 `test/features/transactions/application/create_transaction_use_case_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/application/create_transaction_use_case.dart';
import 'package:billapp/features/transactions/application/get_recent_transactions_use_case.dart';
import 'package:billapp/features/transactions/data/in_memory_transaction_repository.dart';
import 'package:billapp/features/transactions/data/seed_categories.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';
import 'package:billapp/shared/money/money.dart';

void main() {
  test('创建账单后可以在最近账单中看到', () async {
    final repository = InMemoryTransactionRepository();
    final create = CreateTransactionUseCase(repository: repository);
    final getRecent = GetRecentTransactionsUseCase(repository: repository);
    final food = seedCategories.firstWhere((category) => category.id == 'food');

    final transaction = await create(
      type: TransactionType.expense,
      money: Money.parseCny('28'),
      category: food,
      note: '午饭',
      occurredAt: DateTime(2026, 5, 6, 12),
    );

    final recent = await getRecent(limit: 10);

    expect(transaction.amountMinor, 2800);
    expect(recent, hasLength(1));
    expect(recent.single.categoryId, 'food');
    expect(recent.single.note, '午饭');
  });
}
```

- [ ] **Step 2：验证测试失败**

运行：

```powershell
flutter test test/features/transactions/domain/transaction_validator_test.dart test/features/transactions/application/create_transaction_use_case_test.dart
```

预期：失败，原因是账单实体、校验器和用例不存在。

- [ ] **Step 3：实现最小代码**

创建 `lib/features/transactions/domain/transaction.dart`：

```dart
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
```

创建 `lib/features/transactions/domain/transaction_validator.dart`：

```dart
import 'category.dart';
import 'transaction_type.dart';
import '../../../shared/money/money.dart';

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
```

创建 `lib/features/transactions/data/transaction_repository.dart`：

```dart
import '../domain/transaction.dart';

abstract interface class TransactionRepository {
  Future<void> save(Transaction transaction);
  Future<List<Transaction>> getRecent({required int limit});
}
```

创建 `lib/features/transactions/data/in_memory_transaction_repository.dart`：

```dart
import 'transaction_repository.dart';
import '../domain/transaction.dart';

class InMemoryTransactionRepository implements TransactionRepository {
  final List<Transaction> _transactions = [];

  @override
  Future<void> save(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<Transaction>> getRecent({required int limit}) async {
    final active = _transactions.where((transaction) => transaction.deletedAt == null).toList()
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return active.take(limit).toList();
  }
}
```

创建 `lib/features/transactions/application/create_transaction_use_case.dart`：

```dart
import 'package:uuid/uuid.dart';

import '../../../shared/money/money.dart';
import '../data/default_account.dart';
import '../data/transaction_repository.dart';
import '../domain/category.dart';
import '../domain/transaction.dart';
import '../domain/transaction_type.dart';
import '../domain/transaction_validator.dart';

class CreateTransactionUseCase {
  CreateTransactionUseCase({
    required this.repository,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final TransactionRepository repository;
  final Uuid _uuid;

  Future<Transaction> call({
    required TransactionType type,
    required Money money,
    required Category category,
    String? note,
    DateTime? occurredAt,
  }) async {
    TransactionValidator.validateCreate(type: type, money: money, category: category);

    final now = DateTime.now();
    final transaction = Transaction(
      id: _uuid.v4(),
      type: type,
      amountMinor: money.minorUnits,
      categoryId: category.id,
      accountId: defaultAccount.id,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      occurredAt: occurredAt ?? now,
      createdAt: now,
      updatedAt: now,
    );

    await repository.save(transaction);
    return transaction;
  }
}
```

创建 `lib/features/transactions/application/get_recent_transactions_use_case.dart`：

```dart
import '../data/transaction_repository.dart';
import '../domain/transaction.dart';

class GetRecentTransactionsUseCase {
  const GetRecentTransactionsUseCase({required this.repository});

  final TransactionRepository repository;

  Future<List<Transaction>> call({required int limit}) {
    return repository.getRecent(limit: limit);
  }
}
```

- [ ] **Step 4：验证测试通过**

运行：

```powershell
flutter test test/features/transactions/domain/transaction_validator_test.dart test/features/transactions/application/create_transaction_use_case_test.dart
```

预期：通过。

- [ ] **Step 5：提交**

```powershell
git add lib/features/transactions test/features/transactions
git commit -m "feat: create transactions in memory"
```

## Task 5：记账首页闭环

**文件：**
- 创建：`test/features/transactions/presentation/record_screen_test.dart`
- 创建：`lib/features/transactions/presentation/record_screen.dart`
- 修改：`lib/app/bill_app.dart`

- [ ] **Step 1：写失败测试**

创建 `test/features/transactions/presentation/record_screen_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/presentation/record_screen.dart';

void main() {
  testWidgets('输入金额并选择餐饮后创建最近账单', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RecordScreen()));

    await tester.enterText(find.byKey(const Key('amount_input')), '28');
    await tester.tap(find.text('餐饮'));
    await tester.tap(find.text('保存'));
    await tester.pump();

    expect(find.text('28.00'), findsOneWidget);
    expect(find.text('餐饮'), findsWidgets);
  });
}
```

- [ ] **Step 2：验证测试失败**

运行：

```powershell
flutter test test/features/transactions/presentation/record_screen_test.dart
```

预期：失败，原因是 `RecordScreen` 不存在。

- [ ] **Step 3：实现最小 UI 闭环**

创建 `lib/features/transactions/presentation/record_screen.dart`：

```dart
import 'package:flutter/material.dart';

import '../../../shared/money/money.dart';
import '../data/seed_categories.dart';
import '../domain/category.dart';
import '../domain/transaction.dart';
import '../domain/transaction_type.dart';
import '../application/create_transaction_use_case.dart';
import '../application/get_recent_transactions_use_case.dart';
import '../data/in_memory_transaction_repository.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _amountController = TextEditingController();
  final _repository = InMemoryTransactionRepository();
  late final _create = CreateTransactionUseCase(repository: _repository);
  late final _getRecent = GetRecentTransactionsUseCase(repository: _repository);

  TransactionType _type = TransactionType.expense;
  Category? _selectedCategory;
  List<Transaction> _recent = [];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<Category> get _visibleCategories {
    return seedCategories.where((category) => category.type == _type).toList();
  }

  Future<void> _save() async {
    final category = _selectedCategory;
    if (category == null) {
      return;
    }

    await _create(
      type: _type,
      money: Money.parseCny(_amountController.text),
      category: category,
    );
    final recent = await _getRecent(limit: 10);
    setState(() {
      _amountController.clear();
      _recent = recent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记账')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('amount_input'),
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: '金额',
              prefixText: '¥ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(value: TransactionType.expense, label: Text('支出')),
              ButtonSegment(value: TransactionType.income, label: Text('收入')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) {
              setState(() {
                _type = selection.single;
                _selectedCategory = null;
              });
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in _visibleCategories)
                ChoiceChip(
                  label: Text(category.name),
                  selected: _selectedCategory?.id == category.id,
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
          const SizedBox(height: 24),
          Text('最近账单', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final transaction in _recent)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_categoryName(transaction.categoryId)),
              trailing: Text(MoneyDisplay.fromMinorUnits(transaction.amountMinor)),
            ),
        ],
      ),
    );
  }

  String _categoryName(String categoryId) {
    return seedCategories.firstWhere((category) => category.id == categoryId).name;
  }
}

class MoneyDisplay {
  const MoneyDisplay._();

  static String fromMinorUnits(int minorUnits) {
    final yuan = minorUnits ~/ 100;
    final fen = minorUnits % 100;
    return '$yuan.${fen.toString().padLeft(2, '0')}';
  }
}
```

修改 `lib/app/bill_app.dart`：

```dart
import 'package:flutter/material.dart';

import '../features/transactions/presentation/record_screen.dart';

class BillApp extends StatelessWidget {
  const BillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BillAPP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const RecordScreen(),
    );
  }
}
```

- [ ] **Step 4：验证测试通过**

运行：

```powershell
flutter test test/features/transactions/presentation/record_screen_test.dart
flutter test
```

预期：通过。

- [ ] **Step 5：提交**

```powershell
git add lib test
git commit -m "feat: add record screen transaction flow"
```

## 自查结果

- 规格覆盖：本计划覆盖 Sprint 001 的项目初始化、固定分类、默认账户、账单创建、最近账单列表和基础测试。
- 暂未覆盖：真实 Drift/SQLite 持久化、编辑、删除、统计页、导出备份；这些属于后续任务或 Sprint 002。
- 占位符检查：无 `TBD`、`TODO`、`FIXME`。
- 类型一致性：核心类型统一使用 `TransactionType`、`Money`、`Category`、`Transaction`。
