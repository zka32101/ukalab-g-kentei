import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_g_kentei/main.dart';

// MascotWidget は animate: true が既定のため、disableAnimations なしでは
// アニメーションが回り続けて pumpAndSettle がタイムアウトする。
Widget _app() => ProviderScope(
      overrides: [
        coinServiceProvider.overrideWithValue(CoinService(store: InMemoryCoinStore())),
        outfitServiceProvider.overrideWithValue(OutfitService(store: InMemoryOutfitStore())),
      ],
      child: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const UkalabGKenteiApp(),
      ),
    );

void main() {
  testWidgets('起動して問題データを読み込み、ホーム画面が表示される', (tester) async {
    // assets からの読み込みは実際の非同期I/Oのため、pump だけでは
    // fake async のタイミングと競合してタイムアウトすることがある。
    // runAsync で実際の非同期ガップを許可してから反映させる。
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(find.text('うかラボ G検定'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('学ぶ'), findsOneWidget);
    expect(find.text('模擬'), findsOneWidget);
  });

  testWidgets('用語集を開いて検索し、用語カードが開く', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    await tester.tap(find.text('用語集'));
    await tester.pumpAndSettle();
    expect(find.text('用語を検索'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '過学習');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, '過学習'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, '過学習'));
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

  testWidgets('境界線スライダーを開いて条件を切り替えると判定が変わる', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('AIと法律の境界線'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('AIと法律の境界線'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('学習用データの収集（著作権法30条の4）'));
    await tester.pumpAndSettle();
    expect(find.byType(BoundarySliderWidget), findsOneWidget);

    await tester.tap(find.text('作品の思想・感情を享受させる目的を含むか'));
    await tester.pumpAndSettle();
    expect(find.textContaining('享受目的を含むため'), findsOneWidget);
  });

  testWidgets('予測→実行を開いて予測すると正解とのズレが出る', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('予測→実行'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('予測→実行'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('検査のパラドックス'));
    await tester.pumpAndSettle();
    expect(find.byType(PredictRunWidget), findsOneWidget);

    await tester.tap(find.text('予測する'));
    await tester.pumpAndSettle();
    expect(find.text('正解'), findsOneWidget);
    expect(find.text('15%'), findsOneWidget);
  });

  testWidgets('推しの答案を添削を開いて正解をタップすると解説が出る', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_app());
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('推しの答案を添削'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('推しの答案を添削'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('過学習の対策'));
    await tester.pumpAndSettle();
    expect(find.byType(TeachMascotWidget), findsOneWidget);
    expect(find.text('ここが分からない…'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '未知データでの性能(汎化性能)'));
    await tester.pumpAndSettle();
    expect(find.text('わかった!'), findsOneWidget);
  });
}
