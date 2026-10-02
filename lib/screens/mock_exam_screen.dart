import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 「模擬」タブ: 本試験相当の採点（合格ラインの目安は非公開のため70%を目安と明記）。
///
/// 問題データが145問に満たない間は、今あるぶんだけで模擬試験として出題する。
class MockExamScreen extends StatefulWidget {
  const MockExamScreen({super.key, required this.exam, required this.questions});

  final ExamConfig exam;
  final List<Question> questions;

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  bool _started = false;
  int _index = 0;
  final Map<String, int?> _answers = {};
  late List<Question> _picked;
  MockExamResult? _result;

  void _start() {
    final level = widget.exam.levels.first;
    final count = level.questionCount.clamp(1, widget.questions.length);
    setState(() {
      _picked = List<Question>.from(widget.questions)..shuffle();
      _picked = _picked.take(count).toList();
      _answers.clear();
      _index = 0;
      _started = true;
      _result = null;
    });
  }

  void _select(int i) {
    setState(() => _answers[_picked[_index].qid] = i);
  }

  void _next() {
    if (_index + 1 < _picked.length) {
      setState(() => _index++);
    } else {
      final rule = widget.exam.levels.first.passRule;
      setState(() {
        _result = scoreMockExam(questions: _picked, answers: _answers, rule: rule);
      });
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
            passRatio: 0.70,
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
