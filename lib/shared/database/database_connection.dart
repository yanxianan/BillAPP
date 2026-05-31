import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';
import 'database_config.dart';

AppDatabase openAppDatabase({String databaseName = defaultDatabaseName}) {
  return AppDatabase(
    LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, databaseName));
      return NativeDatabase.createInBackground(file);
    }),
  );
}
