import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/exam_repository.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/mock_exam_screen.dart';
import 'screens/record_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: UkalabGKenteiApp()));
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
            HomeScreen(exam: data.exam, questionCount: questions.length),
            LearnScreen(questions: questions),
            MockExamScreen(exam: data.exam, questions: questions),
            const RecordScreen(),
            const SettingsScreen(),
          ],
        );
      },
    );
  }
}
