import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_g_kentei/main.dart';

void main() {
  testWidgets('起動して問題データを読み込み、ホーム画面が表示される', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: UkalabGKenteiApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('うかラボ G検定'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('学ぶ'), findsOneWidget);
    expect(find.text('模擬'), findsOneWidget);
  });
}
