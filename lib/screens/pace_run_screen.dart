import 'dart:async';

import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 「145問ペース走」画面（型④の直前版、決定76）。
///
/// 本番「100分で約145問」のペース感覚を、短縮版（20問×14分）で体感する。
/// 採点は行わず、タイマー・旗（見直し候補）・ペース表示だけを提供する。
class PaceRunScreen extends StatefulWidget {
  const PaceRunScreen({super.key, required this.questions});

  final List<Question> questions;

  static const _config = PaceRunConfig(questionCount: 20, timeLimitSec: 14 * 60);

  @override
  State<PaceRunScreen> createState() => _PaceRunScreenState();
}

class _PaceRunScreenState extends State<PaceRunScreen> {
  static const _runner = PaceRunner(PaceRunScreen._config);

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _started = false;
  bool _finished = false;
  bool _timedOut = false;
  int _index = 0;
  final Set<String> _flagged = {};
  List<Question> _picked = const [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    final count = PaceRunScreen._config.questionCount.clamp(1, widget.questions.length);
    final picked = List<Question>.from(widget.questions)..shuffle();
    setState(() {
      _picked = picked.take(count).toList();
      _flagged.clear();
      _index = 0;
      _elapsed = Duration.zero;
      _started = true;
      _finished = false;
      _timedOut = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final next = _elapsed + const Duration(seconds: 1);
    if (next.inSeconds >= PaceRunScreen._config.timeLimitSec) {
      _finish(timedOut: true);
      return;
    }
    setState(() => _elapsed = next);
  }

  void _toggleFlag(String qid) {
    setState(() {
      if (!_flagged.remove(qid)) _flagged.add(qid);
    });
  }

  void _next() {
    if (_index + 1 < _picked.length) {
      setState(() => _index++);
    } else {
      _finish(timedOut: false);
    }
  }

  void _finish({required bool timedOut}) {
    _timer?.cancel();
    setState(() {
      _finished = true;
      _timedOut = timedOut;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const EmptyState(message: '問題データがまだありません。');
    }
    if (!_started) return _buildIntro(context);
    if (_finished) return _buildResult(context);
    return _buildRun(context);
  }

  Widget _buildIntro(BuildContext context) {
    final config = PaceRunScreen._config;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('145問ペース走', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '本番は100分で約145問（1問あたり約41秒）。'
              'その感覚を${config.questionCount}問・${config.timeLimitSec ~/ 60}分の短縮版で体感します。'
              '採点はせず、ペースと見直し候補（旗）の練習です。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _start, child: const Text('ペース走を始める')),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _timedOut ? '時間切れ' : '最後まで解き終えました',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('解答数: ${_index + (_timedOut ? 0 : 1)} / ${_picked.length}問'),
            Text('見直し候補（旗）: ${_flagged.length}問'),
            const SizedBox(height: 24),
            FilledButton(onPressed: _start, child: const Text('もう一度')),
          ],
        ),
      ),
    );
  }

  Widget _buildRun(BuildContext context) {
    final q = _picked[_index];
    final flagged = _flagged.contains(q.qid);
    final status = _runner.statusAt(answeredCount: _index, elapsed: _elapsed);
    final remaining = PaceRunScreen._config.timeLimitSec - _elapsed.inSeconds;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('残り $minutes:$seconds', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: Icon(flagged ? Icons.flag : Icons.flag_outlined),
                color: flagged ? Theme.of(context).colorScheme.error : null,
                onPressed: () => _toggleFlag(q.qid),
                tooltip: '見直し候補にする',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status.onTrack
                ? 'このペースなら時間内に解き切れそうです（${status.aheadBy >= 0 ? '+' : ''}${status.aheadBy}問）'
                : 'このペースだと時間切れで残り'
                    '${(PaceRunScreen._config.questionCount - status.projectedTotal).clamp(0, PaceRunScreen._config.questionCount)}問'
                    '解けないかもしれません',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status.onTrack ? null : Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 16),
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
                    state: ChoiceState.idle,
                    onTap: _next,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
