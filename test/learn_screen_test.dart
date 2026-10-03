import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_g_kentei/screens/learn_screen.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

Question _question() => const Question(
      qid: 'q1',
      examId: 'g_kentei',
      subjectId: 'ml_overview',
      topicId: 'overfitting',
      prompt: '過学習が起こりやすいのはどの場合か。',
      choices: ['データが少ない場合', 'データが多い場合', '正則化が強い場合', '無関係'],
      answerIndex: 0,
      explanation: '過学習は、訓練データに過剰に適合してしまう現象である。',
      source: QuestionSource.original,
      sourceRef: '自作',
      contentVer: '1',
    );

// PracticeSession は回答と同時に次の問題へ進む実装のため、1問構成では
// 解説パネルを表示する前に結果画面へ遷移してしまう。内部でシャッフルされ
// どちらが先に出題されるか分からないため、2問目も全く同じ内容にして、
// 出題順に関係なく1問目の回答後に解説を確認できるようにする。
Question _question2() => const Question(
      qid: 'q2',
      examId: 'g_kentei',
      subjectId: 'ml_overview',
      topicId: 'overfitting',
      prompt: '過学習が起こりやすいのはどの場合か。',
      choices: ['データが少ない場合', 'データが多い場合', '正則化が強い場合', '無関係'],
      answerIndex: 0,
      explanation: '過学習は、訓練データに過剰に適合してしまう現象である。',
      source: QuestionSource.original,
      sourceRef: '自作',
      contentVer: '1',
    );

Term _term() => const Term(
      termId: 't1',
      examId: 'g_kentei',
      subjectId: 'ml_overview',
      term: '過学習',
      headline: '練習問題は得意だが、新しい問題には弱くなること',
      definition: '学習データに対して過剰に適合してしまい、汎化性能が低下する現象。',
      source: QuestionSource.original,
      sourceRef: '自作',
      contentVer: '1',
    );

void main() {
  testWidgets('正解すると学習コインが付与される', (tester) async {
    final coinService = CoinService(store: InMemoryCoinStore());
    await coinService.load();
    await tester.pumpWidget(ProviderScope(
      overrides: [coinServiceProvider.overrideWithValue(coinService)],
      child: MaterialApp(
        home: Scaffold(
          body: LearnScreen(
            questions: [_question(), _question2()],
            terms: const [],
            sessionSize: 2,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(coinService.balance, 0);
    await tester.tap(find.text('データが少ない場合'));
    await tester.pumpAndSettle();
    expect(coinService.balance, 1);
  });

  testWidgets('問題文・解説文中の用語をタップすると用語カードが開く', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        coinServiceProvider.overrideWithValue(CoinService(store: InMemoryCoinStore())),
      ],
      child: MaterialApp(
        theme: UkalabTheme.light(field: UkalabField.ai, cert: UkalabCert.gKentei),
        home: Scaffold(
          body: LearnScreen(
            questions: [_question(), _question2()],
            terms: [_term()],
            sessionSize: 2,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // 問題文中の「過学習」にタップ用の recognizer が付いていること。
    final questionRichText = tester
        .widgetList<RichText>(find.byType(RichText))
        .firstWhere((rt) => rt.text.toPlainText().contains('過学習が起こりやすい'));
    final questionOuterSpan = questionRichText.text as TextSpan;
    final questionSpan = questionOuterSpan.children!.single as TextSpan;
    final questionMatched = questionSpan.children!
        .whereType<TextSpan>()
        .where((s) => s.recognizer is TapGestureRecognizer)
        .toList();
    expect(questionMatched.map((s) => s.text), ['過学習']);

    // 選択肢をタップして解説を表示させる。
    await tester.tap(find.text('データが少ない場合'));
    await tester.pumpAndSettle();
    expect(find.text('解説'), findsOneWidget);

    // 解説文中の「過学習」をタップすると用語カードが開く。
    final explanationRichText = tester
        .widgetList<RichText>(find.descendant(
          of: find.byType(ExplanationPanel),
          matching: find.byType(RichText),
        ))
        .firstWhere((rt) => rt.text.toPlainText().contains('過学習は、訓練データに'));
    final explanationOuterSpan = explanationRichText.text as TextSpan;
    final explanationSpan = explanationOuterSpan.children!.single as TextSpan;
    final explanationMatched = explanationSpan.children!
        .whereType<TextSpan>()
        .where((s) => s.recognizer is TapGestureRecognizer)
        .toList();
    expect(explanationMatched.map((s) => s.text), ['過学習']);
    (explanationMatched.single.recognizer as TapGestureRecognizer).onTap!();
    await tester.pumpAndSettle();
    expect(find.byType(TermCard), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(TermCard),
        matching: find.text('練習問題は得意だが、新しい問題には弱くなること'),
      ),
      findsOneWidget,
    );
  });
}
