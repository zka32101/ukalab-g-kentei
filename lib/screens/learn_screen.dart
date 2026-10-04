import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../data/progress_store.dart';

/// 「学ぶ」タブ: 短い演習セッション（最小実装。間隔反復・弱点優先は後続）。
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({
    super.key,
    required this.questions,
    required this.terms,
    this.sessionSize = 10,
  });

  final List<Question> questions;
  final List<Term> terms;
  final int sessionSize;

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
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

  Future<void> _select(int i) async {
    if (_answered) return;
    final q = _session.current;
    setState(() {
      _selected = i;
      _answered = true;
    });
    _session.answer(i);
    if (q != null) {
      final correct = i == q.answerIndex;
      await ref.read(progressProvider.notifier).recordAnswer(q.qid, correct: correct);
      await ref.read(coinProvider.notifier).grant(CoinEvent.newQuestion(q.qid));
      final streakDays = ref.read(progressProvider).streakDays;
      if (streakCoinMilestones.contains(streakDays)) {
        await ref.read(coinProvider.notifier).grant(CoinEvent.streak(streakDays));
      }
    }
  }

  void _next() {
    setState(() {
      _selected = null;
      _answered = false;
    });
  }

  List<TermReference> get _termRefs => [
        for (final t in widget.terms) TermReference(termId: t.termId, matchText: t.term),
      ];

  Term? _termById(String termId) {
    for (final t in widget.terms) {
      if (t.termId == termId) return t;
    }
    return null;
  }

  void _openTerm(Term term) {
    showTermCard(
      context,
      term: term.term,
      headline: term.headline,
      definition: term.definition,
      analogy: term.analogy,
      commonMistake: term.commonMistake,
      relatedTerms: [
        for (final id in term.relatedTermIds)
          if (_termById(id) != null)
            RelatedTermRef(termId: id, label: _termById(id)!.term),
      ],
      onRelatedTermTap: (nextId) {
        final next = _termById(nextId);
        if (next == null) return;
        Navigator.of(context).pop();
        _openTerm(next);
      },
    );
  }

  void _onTermTap(String termId) {
    final term = _termById(termId);
    if (term != null) _openTerm(term);
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
            textWidget: TappableTermText(
              text: q.prompt,
              terms: _termRefs,
              onTermTap: _onTermTap,
            ),
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
              bodyWidget: TappableTermText(
                text: q.explanation,
                terms: _termRefs,
                onTermTap: _onTermTap,
              ),
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
