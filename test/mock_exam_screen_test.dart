import 'package:app_common_kit/app_common_kit.dart';
import 'package:ukalab_core/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_g_kentei/screens/mock_exam_screen.dart';
import 'package:ukalab_core/ukalab_core.dart';

import 'test_support.dart';

final exam = ExamConfig.fromJson({
  'examId': 'g_kentei',
  'name': 'テスト',
  'audience': 'adult',
  'subjects': [
    {'subjectId': 'ml_overview', 'name': '機械学習の概要'},
  ],
  'levels': [
    {
      'levelId': 'standard',
      'name': '標準',
      'questionCount': 2,
      'passRule': {'totalPct': 50},
    },
  ],
});

List<Question> _questions() => [
      Question(
        qid: 'q1',
        examId: 'g_kentei',
        subjectId: 'ml_overview',
        topicId: 't',
        prompt: '問1',
        choices: const ['正解', '不正解'],
        answerIndex: 0,
        explanation: 'e',
        source: QuestionSource.original,
        sourceRef: '自作',
        contentVer: '1',
      ),
      Question(
        qid: 'q2',
        examId: 'g_kentei',
        subjectId: 'ml_overview',
        topicId: 't',
        prompt: '問2',
        choices: const ['正解', '不正解'],
        answerIndex: 0,
        explanation: 'e',
        source: QuestionSource.original,
        sourceRef: '自作',
        contentVer: '1',
      ),
    ];

Future<ProviderContainer> _pump(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final coin = CoinService(store: InMemoryCoinStore());
  await coin.load();
  final container = ProviderContainer(overrides: [
    coinServiceProvider.overrideWithValue(coin),
    outfitServiceProvider.overrideWithValue(OutfitService(store: InMemoryOutfitStore())),
    adGateProvider.overrideWithValue(await testAdGate()),
    examStatsServiceProvider.overrideWithValue(FakeExamStatsService()),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(body: MockExamScreen(exam: exam, questions: _questions())),
    ),
  ));
  await tester.pump();
  return container;
}

void main() {
  testWidgets('合格すると模擬試験実施・合格のコインが両方付与される', (tester) async {
    final c = await _pump(tester);
    await tester.tap(find.text('模擬試験を始める'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('正解'));
    await tester.pump();
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('正解'));
    await tester.pump();
    await tester.tap(find.text('結果を見る'));
    await tester.pumpAndSettle();

    expect(c.read(coinProvider).balance, CoinRules.standard.mockDone + CoinRules.standard.mockPass);
  });

  testWidgets('不合格だと模擬試験実施のコインだけ付与される', (tester) async {
    final c = await _pump(tester);
    await tester.tap(find.text('模擬試験を始める'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('不正解'));
    await tester.pump();
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('不正解'));
    await tester.pump();
    await tester.tap(find.text('結果を見る'));
    await tester.pumpAndSettle();

    expect(c.read(coinProvider).balance, CoinRules.standard.mockDone);
  });
}
