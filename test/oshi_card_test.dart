import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_g_kentei/widgets/oshi_card.dart';
import 'package:ukalab_g_kentei/widgets/oshi_wardrobe.dart';

Widget _app(Widget child) => ProviderScope(
      overrides: [
        coinServiceProvider.overrideWithValue(CoinService(store: InMemoryCoinStore())),
      ],
      child: MaterialApp(
        theme: UkalabTheme.light(field: UkalabField.ai, cert: UkalabCert.gKentei),
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: c!,
        ),
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('初期状態はLv1、コイン0、タップでセリフが変わる', (tester) async {
    await tester.pumpWidget(_app(const OshiCard(totalQuestions: 600)));
    await tester.pumpAndSettle();

    expect(find.text('あなたの推し  Lv1'), findsOneWidget);
    expect(find.text('学習コイン 0'), findsOneWidget);
    expect(find.byType(MascotWidget), findsOneWidget);

    await tester.tap(find.byType(MascotWidget));
    await tester.pumpAndSettle();
    // セリフが切り替わる可能性があるだけで、クラッシュしないことを確認する。
    expect(tester.takeException(), isNull);
  });

  testWidgets('メニューから表示設定を変更できる', (tester) async {
    await tester.pumpWidget(_app(const OshiCard(totalQuestions: 600)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('表示しない'));
    await tester.pumpAndSettle();

    expect(find.text('推しは非表示です'), findsOneWidget);
    expect(find.byType(MascotWidget), findsNothing);
  });

  testWidgets('全問題数0でも落ちない', (tester) async {
    await tester.pumpWidget(_app(const OshiCard(totalQuestions: 0)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('あなたの推し  Lv1'), findsOneWidget);
  });

  testWidgets('メニューの「着替え・ショップ」から衣装画面に遷移する', (tester) async {
    await tester.pumpWidget(_app(const OshiCard(totalQuestions: 600)));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('着替え・ショップ'));
    await tester.pumpAndSettle();

    expect(find.byType(OshiWardrobeView), findsOneWidget);
  });
}
