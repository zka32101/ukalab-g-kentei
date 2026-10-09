import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exam_date_store.dart';

/// 受験日の入力。入れると、試験直前の復習モードが受験日の3日前から使える。
class ExamDateTile extends ConsumerWidget {
  const ExamDateTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(examDateProvider);
    return ListTile(
      leading: const Icon(Icons.event),
      title: const Text('受験日'),
      subtitle: Text(
        date == null
            ? '未設定。入力すると直前の復習モードが使えます。'
            : '${date.year}/${date.month}/${date.day}',
      ),
      trailing: date == null
          ? null
          : IconButton(
              tooltip: '受験日を解除',
              icon: const Icon(Icons.clear),
              onPressed: () => ref.read(examDateProvider.notifier).setDate(null),
            ),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? now,
          firstDate: DateTime(now.year, now.month, now.day),
          lastDate: DateTime(now.year + 3, 12, 31),
        );
        if (picked != null) {
          await ref.read(examDateProvider.notifier).setDate(picked);
        }
      },
    );
  }
}
