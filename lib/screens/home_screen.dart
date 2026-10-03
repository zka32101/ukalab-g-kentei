import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../widgets/oshi_card.dart';
import 'boundary_screen.dart';
import 'terms_screen.dart';

/// 「ホーム」タブ。推し・学習コインを表示（決定67〜77）。
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.exam,
    required this.questionCount,
    required this.terms,
    required this.boundaryScenarios,
  });

  final ExamConfig exam;
  final int questionCount;
  final List<Term> terms;
  final List<BoundaryScenario> boundaryScenarios;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            totalQuestions: questionCount,
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
                  Text('$questionCount問', style: theme.textTheme.titleMedium),
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
        ],
      ),
    );
  }
}
