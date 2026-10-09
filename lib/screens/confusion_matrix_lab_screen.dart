import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「評価指標ラボ」一覧（画期的な機能3）。混同行列を動かして正解率・適合率・
/// 再現率・F値の連動を体験し、場面問題を解く。
class ConfusionMatrixLabScreen extends StatelessWidget {
  const ConfusionMatrixLabScreen({super.key, required this.scenarios});

  final List<ConfusionMatrixScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const EmptyState(message: '評価指標ラボのデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = scenarios[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.grid_on_outlined),
            title: Text(s.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(s.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConfusionMatrixLabWidget(
                      scenario: ConfusionMatrixScenarioSpec(
                        title: s.title,
                        description: s.description,
                        initialTp: s.initialTp,
                        initialFp: s.initialFp,
                        initialFn: s.initialFn,
                        initialTn: s.initialTn,
                        options: [
                          for (final o in s.options)
                            FailureChoiceSpec(
                              optionId: o.optionId,
                              text: o.text,
                              isCorrect: o.isCorrect,
                            ),
                        ],
                        explanation: s.explanation,
                      ),
                    ),
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
