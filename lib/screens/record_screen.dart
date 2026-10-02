import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';

/// 「記録」タブ。間隔反復・苦手分析・平均点・偏差値は後続（決定30・50）。
class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.insights_outlined,
      message: '学習の記録はこれから。演習を進めると、ここに成績が表示されます。',
    );
  }
}
