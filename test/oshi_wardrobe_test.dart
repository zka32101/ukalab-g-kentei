import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_g_kentei/widgets/oshi_wardrobe.dart';

Future<ProviderContainer> _pump(WidgetTester tester, {int mockPasses = 0}) async {
  final coin = CoinService(
    store: InMemoryCoinStore(),
    shop: OutfitCatalog.shopItems([UkalabCert.gKentei]),
  );
  await coin.load();
  // 300コイン貯める（mockPass 1回=50、試験IDを変えて複数回付与）。
  for (var i = 0; i < mockPasses; i++) {
    await coin.grant(CoinEvent.mockPass('exam$i'));
  }
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(overrides: [
    coinServiceProvider.overrideWithValue(coin),
    outfitServiceProvider.overrideWithValue(OutfitService(store: InMemoryOutfitStore())),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: OshiWardrobeView()),
  ));
  await tester.pump();
  return container;
}

void main() {
  testWidgets('コインが足りないと買えず、理由を出す', (tester) async {
    await _pump(tester);
    await tester.tap(find.textContaining('コイン').last);
    await tester.pump();
    expect(find.text('コインが足りません。学習すると貯まります'), findsOneWidget);
  });

  testWidgets('合格記念・準備完了・試験日の装いはロック中で、理由が見える', (tester) async {
    await _pump(tester);
    expect(find.text('合格したときに解放されます'), findsOneWidget);
    expect(find.text('準備完了の目標を達成すると解放されます'), findsOneWidget);
    expect(find.text('試験日を設定すると着られます'), findsOneWidget);
  });

  testWidgets('十分なコインで購入→着る', (tester) async {
    final c = await _pump(tester, mockPasses: 6); // 6×50=300 以上
    expect(c.read(coinServiceProvider).balance, greaterThanOrEqualTo(300));
    await c.read(coinProvider.notifier).load();
    await tester.pump();
    await tester.tap(find.text('300コイン'));
    await tester.pump();
    expect(find.text('着る'), findsOneWidget);
    await tester.tap(find.text('着る'));
    await tester.pump();
    expect(c.read(equippedOutfitProvider)?.cert, UkalabCert.gKentei);
    expect(find.text('着ています'), findsOneWidget);
  });
}
