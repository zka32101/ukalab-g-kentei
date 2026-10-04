import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../data/progress_store.dart';
import '../widgets/oshi_card.dart';

/// 「模擬」タブ: 本試験相当の採点（合格ラインの目安は非公開のため70%を目安と明記）。
///
/// 出題は科目別の出題数配分(ExamConfig.levels.subjectQuestionCounts)どおりに
/// 科目ごと抽出する。科目の問題が不足する分はそのまま不足する。
/// 実施でコイン+10、合格で+50(資格ごとに最初の1回のみ)が付与される
/// （決定67〜77）。合格すると、習得度と合わせて「準備完了」の判定も行う。
class MockExamScreen extends ConsumerStatefulWidget {
  const MockExamScreen({super.key, required this.exam, required this.questions});

  final ExamConfig exam;
  final List<Question> questions;

  @override
  ConsumerState<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends ConsumerState<MockExamScreen> {
  bool _started = false;
  int _index = 0;
  final Map<String, int?> _answers = {};
  late List<Question> _picked;
  MockExamResult? _result;

  void _start() {
    final level = widget.exam.levels.first;
    setState(() {
      _picked = pickMockExamQuestions(
        pool: widget.questions,
        level: level,
        seed: DateTime.now().millisecondsSinceEpoch,
      )..shuffle();
      _answers.clear();
      _index = 0;
      _started = true;
      _result = null;
    });
  }

  void _select(int i) {
    setState(() => _answers[_picked[_index].qid] = i);
  }

  Future<void> _finish() async {
    final rule = widget.exam.levels.first.passRule;
    final result = scoreMockExam(questions: _picked, answers: _answers, rule: rule);
    setState(() => _result = result);

    await ref.read(progressProvider.notifier).touchStudyDay();
    await ref.read(coinProvider.notifier).grant(CoinEvent.mockDone());
    final streakDays = ref.read(progressProvider).streakDays;
    if (streakCoinMilestones.contains(streakDays)) {
      await ref.read(coinProvider.notifier).grant(CoinEvent.streak(streakDays));
    }
    if (!result.passed) return;
    await ref.read(coinProvider.notifier).grant(CoinEvent.mockPass(widget.exam.examId));
    await ref.read(progressProvider.notifier).recordMockResult(passed: true);

    final progress = ref.read(progressProvider);
    final mastery = masteryInputFor(
      distinctAnswered: progress.distinctAnswered,
      totalQuestions: widget.questions.length,
      correct: progress.correctCount,
    );
    if (ReadinessRule.standard.isReady(mastery: mastery, mockPassed: progress.mockPassedEver)) {
      await ref.read(outfitProvider.notifier).markReady(UkalabCert.gKentei);
    }
  }

  void _next() {
    if (_index + 1 < _picked.length) {
      setState(() => _index++);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const EmptyState(message: '問題データがまだありません。');
    }
    final level = widget.exam.levels.first;

    if (!_started) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('模擬試験', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '本試験は${level.questionCount}問・${(level.timeLimitSec ?? 0) ~/ 60}分。'
                '合格基準は非公開のため、正答率70%を目安に表示します。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _start, child: const Text('模擬試験を始める')),
            ],
          ),
        ),
      );
    }

    final result = _result;
    if (result != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ResultSummary(
            correct: result.total.score,
            total: result.total.max,
            passRatio: level.passRule.totalPct / 100,
            onRetry: _start,
          ),
        ),
      );
    }

    final q = _picked[_index];
    final selected = _answers[q.qid];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            text: q.prompt,
            index: _index + 1,
            total: _picked.length,
            child: Column(
              children: [
                for (var i = 0; i < q.choices.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  ChoiceTile(
                    label: String.fromCharCode(0x41 + i),
                    text: q.choices[i],
                    state: selected == i ? ChoiceState.selected : ChoiceState.idle,
                    onTap: () => _select(i),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: selected == null ? null : _next,
            child: Text(_index + 1 < _picked.length ? '次へ' : '結果を見る'),
          ),
        ],
      ),
    );
  }
}
