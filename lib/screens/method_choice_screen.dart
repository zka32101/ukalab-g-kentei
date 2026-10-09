import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「手法の選び方」一覧（事例仕分け、画期的な機能6）。事例に対して適切な
/// 手法・モデル・評価指標を選ぶ。
class MethodChoiceScreen extends StatelessWidget {
  const MethodChoiceScreen({super.key, required this.scenarios});

  final List<MethodChoiceScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const EmptyState(message: '手法の選び方のデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = scenarios[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.rule_folder_outlined),
            title: Text(s.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(s.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: MethodChoiceWidget(
                      scenario: MethodChoiceScenarioSpec(
                        title: s.title,
                        caseDescription: s.caseDescription,
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
