import 'package:app_common_kit/app_common_kit.dart';
import 'package:ukalab_core/ui.dart';
import 'package:flutter/material.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 「画像認識の中身を見る」一覧（画期的な機能4）。畳み込みフィルタを当てて
/// 特徴マップの変化を見る。
class ConvLabScreen extends StatelessWidget {
  const ConvLabScreen({super.key, required this.images});

  final List<ConvLabImage> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const EmptyState(message: '画像認識の中身を見るのデータがまだありません。');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: images.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final im = images[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.grid_view_outlined),
            title: Text(im.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(im.title)),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: ConvLabWidget(
                      image: ConvLabImageSpec(
                        title: im.title,
                        description: im.description,
                        grid: im.grid,
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
