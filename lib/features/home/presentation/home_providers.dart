import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/child.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/child_repository.dart';

final childrenListProvider = AsyncNotifierProvider<ChildrenListNotifier, List<Child>>(
  () => ChildrenListNotifier(),
  isAutoDispose: true,
);

class ChildrenListNotifier extends AsyncNotifier<List<Child>> {
  ChildRepository get _repository => ref.read(childRepositoryProvider);

  @override
  FutureOr<List<Child>> build() async {
    return _repository.getAllChildren();
  }

  Future<void> loadChildren() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllChildren());
  }

  Future<void> deleteChild(String id) async {
    await _repository.deleteChild(id);
    await loadChildren();
  }
}
