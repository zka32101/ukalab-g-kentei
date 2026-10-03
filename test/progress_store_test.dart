import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_g_kentei/data/progress_store.dart';

ProviderContainer _container() {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  return c;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('recordAnswer で正誤を記録する', () async {
    final c = _container();
    await c.read(progressProvider.notifier).recordAnswer('q1', correct: true);
    await c.read(progressProvider.notifier).recordAnswer('q2', correct: false);
    final state = c.read(progressProvider);
    expect(state.distinctAnswered, 2);
    expect(state.correctCount, 1);
  });

  test('recordMockResult(passed: true) で mockPassedEver が立つ', () async {
    final c = _container();
    expect(c.read(progressProvider).mockPassedEver, isFalse);
    await c.read(progressProvider.notifier).recordMockResult(passed: true);
    expect(c.read(progressProvider).mockPassedEver, isTrue);
  });

  test('recordMockResult(passed: false) は mockPassedEver を変えない', () async {
    final c = _container();
    await c.read(progressProvider.notifier).recordMockResult(passed: false);
    expect(c.read(progressProvider).mockPassedEver, isFalse);
  });

  test('一度 true になった mockPassedEver は false にならない', () async {
    final c = _container();
    await c.read(progressProvider.notifier).recordMockResult(passed: true);
    await c.read(progressProvider.notifier).recordMockResult(passed: false);
    expect(c.read(progressProvider).mockPassedEver, isTrue);
  });
}
