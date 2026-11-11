import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database_service.dart';
import 'child_repository.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return ChildRepository(dbService);
});
