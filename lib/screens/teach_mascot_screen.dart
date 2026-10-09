import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「推しの答案を添削」一覧（型③、決定76・77）。推しが出す誤った答案の
/// 誤りをタップして直す。推しの成長(Lv)はこの演出とは独立している。
class TeachMascotScreen extends StatelessWidget {
  const TeachMascotScreen({super.key, required this.scenarios});

  final List<MisconceptionScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const EmptyState(message: '推しの答案を添削するデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = scenarios[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: Text(s.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(s.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: TeachMascotWidget(
                      title: s.title,
                      statementTemplate: s.statementTemplate,
                      options: [
                        for (final o in s.options)
                          MisconceptionChoiceSpec(
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
        );
      },
    );
  }
}
