import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 「ホーム」タブ。推し・コインは後続で追加（決定67〜77）。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.exam, required this.questionCount});

  final ExamConfig exam;
  final int questionCount;

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
          const SizedBox(height: 24),
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
        ],
      ),
    );
  }
}
