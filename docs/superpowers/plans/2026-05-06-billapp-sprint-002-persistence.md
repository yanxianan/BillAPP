# BillAPP Sprint 002 本地持久化实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标：** 使用 Drift + SQLite 替换 Sprint 001 的内存账单仓储，让账单保存到本地数据库，并在 App 重启后仍可查询。

**架构：** 保持现有分层结构。新增 `shared/database` 放置 Drift 数据库和连接工厂，`features/transactions/data` 新增 SQLite Repository 实现。UI 层只依赖 `TransactionRepository` 接口，不直接接触 Drift。

**技术栈：** Flutter、Dart、Drift、SQLite、sqlite3_flutter_libs、path_provider、build_runner、flutter_test。

---

## 文件结构

- 修改：`pubspec.yaml`，添加 Drift、SQLite 和代码生成依赖。
- 修改：`pubspec.lock`，锁定依赖。
- 创建：`lib/shared/database/app_database.dart`，Drift 数据库定义。
- 生成：`lib/shared/database/app_database.g.dart`，Drift 生成文件。
- 创建：`lib/shared/database/database_connection.dart`，移动端 SQLite 连接工厂。
- 创建：`lib/features/transactions/data/sqlite_transaction_repository.dart`，SQLite 仓储实现。
- 修改：`lib/features/transactions/presentation/record_screen.dart`，默认使用 SQLite 仓储。
- 创建：`test/features/transactions/data/sqlite_transaction_repository_test.dart`，持久化仓储测试。
- 修改：`test/features/transactions/presentation/record_screen_test.dart`，允许注入测试仓储，保持 UI 测试快速稳定。

## Task 1：添加 Drift 依赖

**文件：**
- 修改：`pubspec.yaml`
- 修改：`pubspec.lock`

- [ ] **Step 1：修改依赖**

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  drift: ^2.22.1
  path: ^1.9.1
  path_provider: ^2.1.5
  sqlite3_flutter_libs: ^0.5.26

dev_dependencies:
  build_runner: ^2.4.13
  drift_dev: ^2.22.1
```

- [ ] **Step 2：安装依赖**

运行：

```powershell
flutter pub get
```

预期：依赖解析成功，`pubspec.lock` 更新。

- [ ] **Step 3：提交**

```powershell
git add pubspec.yaml pubspec.lock
git commit -m "chore: add Drift SQLite dependencies"
```

## Task 2：定义 Drift 数据库

**文件：**
- 创建：`lib/shared/database/app_database.dart`
- 生成：`lib/shared/database/app_database.g.dart`

- [ ] **Step 1：写数据库定义**

创建 `lib/shared/database/app_database.dart`：

```dart
import 'package:drift/drift.dart';

part 'app_database.g.dart';

class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get categoryId => text()();
  TextColumn get accountId => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TransactionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
```

- [ ] **Step 2：生成 Drift 代码**

运行：

```powershell
dart run build_runner build --delete-conflicting-outputs
```

预期：生成 `lib/shared/database/app_database.g.dart`。

- [ ] **Step 3：运行分析**

运行：

```powershell
flutter analyze
```

预期：无问题。

- [ ] **Step 4：提交**

```powershell
git add lib/shared/database/app_database.dart lib/shared/database/app_database.g.dart
git commit -m "feat: add Drift app database"
```

## Task 3：实现 SQLite 账单仓储

**文件：**
- 创建：`test/features/transactions/data/sqlite_transaction_repository_test.dart`
- 创建：`lib/features/transactions/data/sqlite_transaction_repository.dart`

- [ ] **Step 1：写失败测试**

创建 `test/features/transactions/data/sqlite_transaction_repository_test.dart`：

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billapp/features/transactions/data/sqlite_transaction_repository.dart';
import 'package:billapp/features/transactions/domain/transaction.dart';
import 'package:billapp/features/transactions/domain/transaction_type.dart';
import 'package:billapp/shared/database/app_database.dart';

void main() {
  test('保存账单后可以从 SQLite 查询最近账单', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = SqliteTransactionRepository(database);

    await repository.save(
      Transaction(
        id: 'txn_1',
        type: TransactionType.expense,
        amountMinor: 2800,
        categoryId: 'food',
        accountId: 'default_cash',
        note: '午饭',
        occurredAt: DateTime(2026, 5, 6, 12),
        createdAt: DateTime(2026, 5, 6, 12),
        updatedAt: DateTime(2026, 5, 6, 12),
      ),
    );

    final recent = await repository.getRecent(limit: 10);

    expect(recent, hasLength(1));
    expect(recent.single.id, 'txn_1');
    expect(recent.single.amountMinor, 2800);
    expect(recent.single.categoryId, 'food');
    expect(recent.single.note, '午饭');
  });
}
```

- [ ] **Step 2：验证测试失败**

运行：

```powershell
flutter test test/features/transactions/data/sqlite_transaction_repository_test.dart
```

预期：失败，原因是 `SqliteTransactionRepository` 不存在。

- [ ] **Step 3：实现仓储**

创建 `lib/features/transactions/data/sqlite_transaction_repository.dart`：

```dart
import '../../../shared/database/app_database.dart';
import '../domain/transaction.dart';
import '../domain/transaction_type.dart';
import 'transaction_repository.dart';

class SqliteTransactionRepository implements TransactionRepository {
  const SqliteTransactionRepository(this.database);

  final AppDatabase database;

  @override
  Future<void> save(Transaction transaction) async {
    await database.into(database.transactionsTable).insertOnConflictUpdate(
          TransactionsTableCompanion.insert(
            id: transaction.id,
            type: transaction.type.name,
            amountMinor: transaction.amountMinor,
            categoryId: transaction.categoryId,
            accountId: transaction.accountId,
            note: Value(transaction.note),
            occurredAt: transaction.occurredAt,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
            deletedAt: Value(transaction.deletedAt),
          ),
        );
  }

  @override
  Future<List<Transaction>> getRecent({required int limit}) async {
    final rows = await (database.select(database.transactionsTable)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.occurredAt)])
          ..limit(limit))
        .get();

    return rows.map(_toDomain).toList();
  }

  Transaction _toDomain(TransactionsTableData row) {
    return Transaction(
      id: row.id,
      type: TransactionType.values.byName(row.type),
      amountMinor: row.amountMinor,
      categoryId: row.categoryId,
      accountId: row.accountId,
      note: row.note,
      occurredAt: row.occurredAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
```

- [ ] **Step 4：验证测试通过**

运行：

```powershell
flutter test test/features/transactions/data/sqlite_transaction_repository_test.dart
```

预期：通过。

- [ ] **Step 5：提交**

```powershell
git add lib/features/transactions/data/sqlite_transaction_repository.dart test/features/transactions/data/sqlite_transaction_repository_test.dart
git commit -m "feat: persist transactions with SQLite repository"
```

## Task 4：接入 App 数据库连接

**文件：**
- 创建：`lib/shared/database/database_connection.dart`
- 修改：`lib/features/transactions/presentation/record_screen.dart`
- 修改：`test/features/transactions/presentation/record_screen_test.dart`

- [ ] **Step 1：创建数据库连接工厂**

创建 `lib/shared/database/database_connection.dart`：

```dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

AppDatabase openAppDatabase() {
  return AppDatabase(
    LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'billapp.sqlite'));
      return NativeDatabase.createInBackground(file);
    }),
  );
}
```

- [ ] **Step 2：让记账页默认使用 SQLite 仓储，同时支持测试注入**

修改 `lib/features/transactions/presentation/record_screen.dart`，让构造函数支持 `TransactionRepository? repository`，默认使用：

```dart
RecordScreen({super.key, TransactionRepository? repository})
    : repository = repository ??
          SqliteTransactionRepository(openAppDatabase());
```

并将内部仓储字段改为：

```dart
final TransactionRepository repository;
```

用例初始化改为使用 `widget.repository`。

- [ ] **Step 3：更新 UI 测试注入内存仓储**

修改 `test/features/transactions/presentation/record_screen_test.dart`：

```dart
await tester.pumpWidget(
  MaterialApp(
    home: RecordScreen(repository: InMemoryTransactionRepository()),
  ),
);
```

- [ ] **Step 4：运行全量验证**

运行：

```powershell
flutter analyze
flutter test
```

预期：无分析问题，所有测试通过。

- [ ] **Step 5：提交**

```powershell
git add lib test
git commit -m "feat: use SQLite repository in record screen"
```

## 自查结果

- 规格覆盖：本计划覆盖“本地持久化”和“App 重启后账单不丢”的技术基础。
- 暂未覆盖：编辑、删除、统计页、导出备份；这些进入后续 Sprint。
- 占位符检查：无待定项。
- 类型一致性：沿用 Sprint 001 的 `TransactionRepository`、`Transaction`、`TransactionType`。

