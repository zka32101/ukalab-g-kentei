import 'package:flutter/material.dart';

/// 「設定」タブ。課金・広告・通知の設定は後続（app_common_kit v0.1 の組み込み時）。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          title: Text('このアプリについて'),
          subtitle: Text(
            '「うかラボ G検定」は、一般社団法人日本ディープラーニング協会（JDLA）とは'
            '無関係に開発・運営する非公式の学習アプリです。問題はすべて独自に作成しています。',
          ),
        ),
        Divider(height: 1),
        ListTile(
          title: Text('バージョン'),
          subtitle: Text('0.1.0'),
        ),
      ],
    );
  }
}
