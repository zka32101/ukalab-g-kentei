import 'package:app_common_kit/app_common_kit.dart';
import 'package:ukalab_core/ui.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「学習の失敗図鑑」一覧（型⑦、決定76）。学習曲線を見て症状を当て、
/// 処方（対策）を選ぶ。
class FailureGalleryScreen extends StatelessWidget {
  const FailureGalleryScreen({super.key, required this.cases});

  final List<FailureCase> cases;

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) {
      return const EmptyState(message: '学習の失敗図鑑のデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final c = cases[i];
        final title = '症例${i + 1}';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.show_chart_outlined),
            title: Text(title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: FailureGalleryWidget(
                      title: title,
                      curve: [
                        for (final p in c.curve)
                          LearningCurvePointSpec(
                            epoch: p.epoch,
                            trainLoss: p.trainLoss,
                            valLoss: p.valLoss,
                          ),
                      ],
                      symptomOptions: [
                        for (final o in c.symptomOptions)
                          FailureChoiceSpec(
                            optionId: o.optionId,
                            text: o.text,
                            isCorrect: o.isCorrect,
                          ),
                      ],
                      treatmentOptions: [
                        for (final o in c.treatmentOptions)
                          FailureChoiceSpec(
                            optionId: o.optionId,
                            text: o.text,
                            isCorrect: o.isCorrect,
                          ),
                      ],
                      explanation: c.explanation,
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
