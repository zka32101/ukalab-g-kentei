import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 「学ぶ」タブ: 短い演習セッション（最小実装。間隔反復・弱点優先は後続）。
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, required this.questions, this.sessionSize = 10});

  final List<Question> questions;
  final int sessionSize;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late PracticeSession _session = _newSession();
  int? _selected;
  bool _answered = false;

  PracticeSession _newSession() => PracticeSession(
        pool: widget.questions,
        size: widget.sessionSize.clamp(1, widget.questions.length),
        seed: DateTime.now().millisecondsSinceEpoch,
      );

  void _restart() {
    setState(() {
      _session = _newSession();
      _selected = null;
      _answered = false;
    });
  }

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
    });
    _session.answer(i);
  }

  void _next() {
    setState(() {
      _selected = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const EmptyState(message: '問題データがまだありません。');
    }
    final q = _session.current;
    if (q == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ResultSummary(
            correct: _session.correctCount,
            total: _session.questions.length,
            onRetry: _restart,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            text: q.prompt,
            index: _session.index + 1,
            total: _session.questions.length,
            child: Column(
              children: [
                for (var i = 0; i < q.choices.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  ChoiceTile(
                    label: String.fromCharCode(0x41 + i),
                    text: q.choices[i],
                    state: !_answered
                        ? (_selected == i ? ChoiceState.selected : ChoiceState.idle)
                        : (i == q.answerIndex
                            ? ChoiceState.correct
                            : (i == _selected ? ChoiceState.incorrect : ChoiceState.idle)),
                    onTap: () => _select(i),
                  ),
                ],
              ],
            ),
          ),
          if (_answered) ...[
            const SizedBox(height: 16),
            ExplanationPanel(
              body: q.explanation,
              sourceRef: q.sourceRef,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _next, child: const Text('次へ')),
          ],
        ],
      ),
    );
  }
}
