import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_g_kentei/screens/pace_run_screen.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

List<Question> _questions(int count) => [
      for (var i = 0; i < count; i++)
        Question(
          qid: 'q$i',
          examId: 'g_kentei',
          subjectId: 'ml_overview',
          topicId: 't',
          prompt: '問題$i',
          choices: const ['正解', '不正解'],
          answerIndex: 0,
          explanation: 'e',
          source: QuestionSource.original,
          sourceRef: '自作',
          contentVer: '1',
        ),
    ];

Future<void> _pump(WidgetTester tester, List<Question> questions) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: PaceRunScreen(questions: questions)),
  ));
  await tester.pump();
}

void main() {
  testWidgets('開始前は説明と開始ボタンが出る', (tester) async {
    await _pump(tester, _questions(25));
    expect(find.text('145問ペース走'), findsOneWidget);
    expect(find.text('ペース走を始める'), findsOneWidget);
  });

  testWidgets('開始すると1問目とタイマー・旗ボタンが出る', (tester) async {
    await _pump(tester, _questions(25));
    await tester.tap(find.text('ペース走を始める'));
    await tester.pump();

    expect(find.text('問題0'), findsNothing); // プロンプトはシャッフルされるため個別の値は見ない
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(find.textContaining('残り'), findsOneWidget);
  });

  testWidgets('旗ボタンをタップすると見直し候補になる', (tester) async {
    await _pump(tester, _questions(25));
    await tester.tap(find.text('ペース走を始める'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.flag_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.flag), findsOneWidget);

    await tester.tap(find.byIcon(Icons.flag));
    await tester.pump();
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
  });

  testWidgets('選択肢をタップすると次の問題に進み、最後まで進むと結果画面になる', (tester) async {
    await _pump(tester, _questions(2));
    await tester.tap(find.text('ペース走を始める'));
    await tester.pump();

    await tester.tap(find.text('正解').first);
    await tester.pump();
    await tester.tap(find.text('正解').first);
    await tester.pump();

    expect(find.text('最後まで解き終えました'), findsOneWidget);
    expect(find.textContaining('解答数: 2 / 2問'), findsOneWidget);
  });

  testWidgets('問題データが0件でも落ちない', (tester) async {
    await _pump(tester, const []);
    expect(tester.takeException(), isNull);
  });
}
