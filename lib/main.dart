import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/exam_repository.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/mock_exam_screen.dart';
import 'screens/record_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/oshi_wardrobe.dart';

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

  final container = ProviderContainer(
    overrides: [
      coinServiceProvider.overrideWithValue(coinService),
      outfitServiceProvider.overrideWithValue(outfitService),
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
              questionCount: questions.length,
              terms: data.terms,
              boundaryScenarios: data.boundaryScenarios,
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
