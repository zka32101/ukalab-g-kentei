import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「Transformerの注意の可視化」一覧（画期的な機能5）。単語同士の注意
/// （Attention）の強さを線の太さ・濃さで見る。
class AttentionVizScreen extends StatelessWidget {
  const AttentionVizScreen({super.key, required this.scenarios});

  final List<AttentionVizScenario> scenarios;

  @override
  Widget build(BuildContext context) {
    if (scenarios.isEmpty) {
      return const EmptyState(message: 'Transformerの注意の可視化のデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final s = scenarios[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(s.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(s.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: AttentionVizWidget(
                      scenario: AttentionVizSpec(
                        title: s.title,
                        description: s.description,
                        tokens: s.tokens,
                        attention: s.attention,
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
