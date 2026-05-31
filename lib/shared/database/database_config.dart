/// Default SQLite database file name.
///
/// On mobile/desktop this file is created inside the directory returned by
/// `getApplicationDocumentsDirectory()` from `path_provider`.
/// In tests the database runs in-memory, so this constant is unused.
const String defaultDatabaseName = 'billapp.sqlite';
