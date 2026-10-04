import 'dart:io' show Platform;

import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/exam_repository.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/mock_exam_screen.dart';
import 'screens/record_screen.dart';
import 'screens/settings_screen.dart';

/// Google公式のテスト広告ユニットID。本番公開前に実際のIDへ差し替える（決定35）。
AdUnitIds _testAdUnitIds() => Platform.isIOS
    ? const AdUnitIds(
        banner: 'ca-app-pub-3940256099942544/2934735716',
        interstitial: 'ca-app-pub-3940256099942544/4411468910',
        rewarded: 'ca-app-pub-3940256099942544/1712485313',
      )
    : const AdUnitIds(
        banner: 'ca-app-pub-3940256099942544/6300978111',
        interstitial: 'ca-app-pub-3940256099942544/1033173712',
        rewarded: 'ca-app-pub-3940256099942544/5224354917',
      );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 学習コイン・衣装（app_common_kit）。財布・衣装台帳はアプリごとに端末内保存
  // （決定67〜77）。ショップには通常衣装（G検定、コイン購入）だけを並べる。
  final coinService = CoinService(
    store: SharedPreferencesCoinStore('g_kentei'),
    shop: OutfitCatalog.shopItems([UkalabCert.gKentei]),
  );
  await coinService.load();

  final outfitService = OutfitService(store: SharedPreferencesOutfitStore('g_kentei'));
  await outfitService.load();

  // 課金（RevenueCat）は未着手のため、権利は常に無料として扱う
  // （noads/premiumの実装後にRevenueCatEntitlementServiceへ差し替える）。
  final entitlementService = FakeEntitlementService();

  // 広告（AdMob、決定35）。noads/premiumの間は何も表示しない。
  final adGate = await AdGate.init(
    config: AdConfig(unitIds: _testAdUnitIds()),
    adsHidden: () => entitlementService.state.adsHidden,
    isRelease: kReleaseMode,
  );

  final container = ProviderContainer(
    overrides: [
      coinServiceProvider.overrideWithValue(coinService),
      outfitServiceProvider.overrideWithValue(outfitService),
      entitlementServiceProvider.overrideWithValue(entitlementService),
      adGateProvider.overrideWithValue(adGate),
    ],
  );

  runApp(UncontrolledProviderScope(
    container: container,
    child: const UkalabGKenteiApp(),
  ));
}

class UkalabGKenteiApp extends StatelessWidget {
  const UkalabGKenteiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'うかラボ G検定',
      debugShowCheckedModeBanner: false,
      theme: UkalabTheme.light(field: UkalabField.ai, cert: UkalabCert.gKentei),
      darkTheme: UkalabTheme.dark(field: UkalabField.ai, cert: UkalabCert.gKentei),
      home: const _RootPage(),
    );
  }
}

class _RootPage extends ConsumerWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examData = ref.watch(examDataProvider);
    return examData.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: ErrorState(
          message: '問題データを読み込めませんでした。\n$e',
          onRetry: () => ref.invalidate(examDataProvider),
        ),
      ),
      data: (data) {
        final questions = data.activeQuestions;
        return UkalabShell(
          pages: [
            HomeScreen(
              exam: data.exam,
              questions: questions,
              terms: data.terms,
              boundaryScenarios: data.boundaryScenarios,
              predictRunScenarios: data.predictRunScenarios,
              misconceptionScenarios: data.misconceptionScenarios,
              failureCases: data.failureCases,
            ),
            LearnScreen(questions: questions, terms: data.terms),
            MockExamScreen(exam: data.exam, questions: questions),
            const RecordScreen(),
            const SettingsScreen(),
          ],
        );
      },
    );
  }
}
