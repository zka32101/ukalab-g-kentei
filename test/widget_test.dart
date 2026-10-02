import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_g_kentei/main.dart';

void main() {
  testWidgets('起動して問題データを読み込み、ホーム画面が表示される', (tester) async {
    // assets からの読み込みは実際の非同期I/Oのため、pump だけでは
    // fake async のタイミングと競合してタイムアウトすることがある。
    // runAsync で実際の非同期ガップを許可してから反映させる。
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(child: UkalabGKenteiApp()),
      );
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    expect(find.text('うかラボ G検定'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('学ぶ'), findsOneWidget);
    expect(find.text('模擬'), findsOneWidget);
  });
}
