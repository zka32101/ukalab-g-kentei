import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「境界線スライダー」一覧（型①、決定76・77）。条件を1つずつ切り替え、
/// 判定が切り替わる「ちょうど境目」を体験する。
class BoundaryScreen extends StatelessWidget {
  const BoundaryScreen({super.key, required this.scenarios});

  final List<BoundaryScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const EmptyState(message: '境界線スライダーのデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = scenarios[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.balance_outlined),
            title: Text(s.title),
            subtitle: Text('条件${s.conditions.length}つを切り替えて判定の変化を体験'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(s.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _BoundaryScenarioView(scenario: s),
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

class _BoundaryScenarioView extends StatelessWidget {
  const _BoundaryScenarioView({required this.scenario});

  final BoundaryScenario scenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoundarySliderWidget(
          title: scenario.title,
          conditions: [
            for (final c in scenario.conditions)
              BoundaryConditionSpec(
                conditionId: c.conditionId,
                label: c.label,
                trueLabel: c.trueLabel,
                falseLabel: c.falseLabel,
              ),
          ],
          evaluate: (values) {
            final rule = scenario.evaluate(values);
            if (rule == null) return null;
            return BoundaryConclusion(
              text: rule.conclusion,
              lawReference: rule.lawReference,
            );
          },
        ),
        const SizedBox(height: 20),
        Text('出典', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(scenario.sourceRef, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
