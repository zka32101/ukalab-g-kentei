import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「機械学習ラボ」一覧（画期的な機能1）。点を置いてk近傍法・決定木・線形
/// 分類の境界を見る。
class MlLabScreen extends StatelessWidget {
  const MlLabScreen({super.key, required this.datasets});

  final List<MlLabDataset> datasets;

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty) {
      return const EmptyState(message: '機械学習ラボのデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: datasets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final d = datasets[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.scatter_plot_outlined),
            title: Text(d.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(d.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: MlLabWidget(
                      title: d.title,
                      description: d.description,
                      points: [
                        for (final p in d.points)
                          MlLabPointSpec(x: p.x, y: p.y, label: p.label),
                      ],
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
