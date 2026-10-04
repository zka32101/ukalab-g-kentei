import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../widgets/oshi_card.dart';
import 'boundary_screen.dart';
import 'failure_gallery_screen.dart';
import 'pace_run_screen.dart';
import 'predict_run_screen.dart';
import 'route_planner_screen.dart';
import 'teach_mascot_screen.dart';
import 'term_map_screen.dart';
import 'terms_screen.dart';

/// 「ホーム」タブ。推し・学習コインを表示（決定67〜77）。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.exam,
    required this.questions,
    required this.terms,
    required this.boundaryScenarios,
    required this.predictRunScenarios,
    required this.misconceptionScenarios,
    required this.failureCases,
  });

  final ExamConfig exam;
  final List<Question> questions;
  final List<Term> terms;
  final List<BoundaryScenario> boundaryScenarios;
  final List<PredictRunScenario> predictRunScenarios;
  final List<MisconceptionScenario> misconceptionScenarios;
  final List<FailureCase> failureCases;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final adGate = ref.watch(adGateProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('うかラボ G検定', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'JDLA Deep Learning for GENERAL 対策（JDLAとは無関係の非公式アプリ）',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          OshiCard(
            totalQuestions: questions.length,
            examDate: exam.examDates.isEmpty ? null : exam.examDates.first,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('収録問題数', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text('${questions.length}問', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(
                    '「学ぶ」タブで分野別に演習、「模擬」タブで本番形式の採点ができます。',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('用語集'),
              subtitle: Text('収録${terms.length}語。わからない用語をいつでも調べられます。'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('用語集')),
                    body: TermsScreen(exam: exam, terms: terms),
                  ),
                ),
              ),
            ),
          ),
          if (boundaryScenarios.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.balance_outlined),
                title: const Text('AIと法律の境界線'),
                subtitle: const Text('条件を切り替えて、判定が変わる「境目」を体験できます。'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('AIと法律の境界線')),
                      body: BoundaryScreen(scenarios: boundaryScenarios),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (predictRunScenarios.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.timeline_outlined),
                title: const Text('予測→実行'),
                subtitle: const Text('先に答えを予測してから、計算結果とのズレを体験できます。'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('予測→実行')),
                      body: PredictRunScreen(scenarios: predictRunScenarios),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (misconceptionScenarios.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text('推しの答案を添削'),
                subtitle: const Text('推しの誤りをタップして直すと、「わかった!」の反応が見られます。'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('推しの答案を添削')),
                      body: TeachMascotScreen(scenarios: misconceptionScenarios),
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (failureCases.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.show_chart_outlined),
                title: const Text('学習の失敗図鑑'),
                subtitle: const Text('学習曲線を見て症状を当て、処方（対策）を選びます。'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: const Text('学習の失敗図鑑')),
                      body: FailureGalleryScreen(cases: failureCases),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.route_outlined),
              title: const Text('最短ルートプランナー'),
              subtitle: const Text('残り日数・弱点から「今日やる3つ」を出します。'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => RoutePlannerScreen(
                    exam: exam,
                    level: exam.levels.first,
                    questions: questions,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('145問ペース走'),
              subtitle: const Text('本番のペース感覚を短縮版（20問・14分）で体感します。'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('145問ペース走')),
                    body: PaceRunScreen(questions: questions),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.hub_outlined),
              title: const Text('用語マップ・AI系譜図'),
              subtitle: const Text('関連する用語をつないだ地図と、AIの歴史のタイムラインです。'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('用語マップ・AI系譜図')),
                    body: TermMapScreen(terms: terms),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: adGate.banner(BannerPlacement.home)),
        ],
      ),
    );
  }
}
