import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 「ニューラルネット組み立て」一覧（画期的な機能2）。隠れ層・ユニット数・
/// 活性化関数・学習率を選び、小さな全結合ニューラルネットを実際に学習させて
/// 決定境界・学習曲線の変化を見る。
class NnBuilderScreen extends StatelessWidget {
  const NnBuilderScreen({super.key, required this.datasets});

  final List<NnBuilderDataset> datasets;

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty) {
      return const EmptyState(message: 'ニューラルネット組み立てのデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: datasets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final d = datasets[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: Text(d.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(d.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: NnBuilderWidget(
                      title: d.title,
                      description: d.description,
                      points: [
                        for (final p in d.points)
                          NnBuilderPointSpec(x: p.x, y: p.y, label: p.label),
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
