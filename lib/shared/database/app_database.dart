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
