import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';

part 'app_database_provider.g.dart';

@Riverpod(keepAlive: true)
Future<AppDatabase> appDatabase(Ref ref) async {
  final executor = await openAppDatabaseConnection();
  final db = AppDatabase(executor);
  ref.onDispose(() {
    unawaited(db.close());
  });
  return db;
}
