import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 「予測→実行」一覧（型②、決定76）。先に答えを予測してから、計算結果との
/// ズレを見て学ぶ。
class PredictRunScreen extends StatelessWidget {
  const PredictRunScreen({super.key, required this.scenarios});

  final List<PredictRunScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const EmptyState(message: '予測→実行のデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = scenarios[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.timeline_outlined),
            title: Text(s.title),
            subtitle: Text(s.question, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(s.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _PredictRunScenarioView(scenario: s),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PredictRunScenarioView extends StatelessWidget {
  const _PredictRunScenarioView({required this.scenario});

  final PredictRunScenario scenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPercent = scenario.kind != PredictRunKind.expectedValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PredictRunWidget(
          title: scenario.title,
          question: scenario.question,
          correctAnswer: scenario.compute(),
          explanation: scenario.explanation,
          min: isPercent ? 0 : 0,
          max: isPercent ? 1 : _outcomeMax(scenario),
          valueLabel: isPercent ? null : (v) => '${v.round()}円',
        ),
        const SizedBox(height: 20),
        Text('出典', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(scenario.sourceRef, style: theme.textTheme.bodySmall),
      ],
    );
  }

  double _outcomeMax(PredictRunScenario s) {
    if (s.outcomes.isEmpty) return 1;
    return s.outcomes.map((o) => o.value).reduce((a, b) => a > b ? a : b);
  }
}
