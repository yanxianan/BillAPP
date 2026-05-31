# BillAPP

极简快速记账 App，使用 Flutter + Drift (SQLite) 构建。

## Prerequisites

- Flutter SDK >= 3.4.0

## Getting Started

```bash
flutter pub get
flutter run
```

## Database Configuration

BillAPP uses SQLite via [Drift](https://drift.simonbinder.eu/) for local persistence.

| Setting | Default | Location |
|---------|---------|----------|
| Database file name | `billapp.sqlite` | `lib/shared/database/database_config.dart` |
| Database directory | OS app-documents dir | Resolved at runtime via `path_provider` |

The database file name is defined in `database_config.dart` as `defaultDatabaseName`
and referenced by `database_connection.dart`. See `.env.example` for a summary of
environment-level configuration.

Tests use an in-memory database (`NativeDatabase.memory()`) so no file is created
during test runs.

## Running Tests

```bash
flutter test
```

### With Docker

```bash
docker compose run --rm test
```

## CI

GitHub Actions runs analysis and tests on every push and PR to `main`.
See `.github/workflows/ci.yml`.

## Code Generation (Drift)

After modifying `app_database.dart`, regenerate the Drift code:

```bash
dart run build_runner build --delete-conflicting-outputs
```
