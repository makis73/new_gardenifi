import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestNotifier extends StateNotifier<AsyncValue<bool>> {
  TestNotifier() : super(const AsyncData(false));

  Future<void> startTest() async {
    state = const AsyncLoading();
    log('From repo: $state');
    await Future.delayed(const Duration(seconds: 3));
    state = const AsyncData(true);
    log('From repo: $state');
  }
}

final testProvider = StateNotifierProvider<TestNotifier, AsyncValue<bool>>((ref) {
  return TestNotifier();
});
