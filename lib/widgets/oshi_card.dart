import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/progress_store.dart';
import 'oshi_wardrobe.dart';

/// 習得度から推しの成長段階を決める。網羅率＝解いた問題の種類数÷全問題数、
/// 正答率＝qidごとの最新の正誤に基づく正答率。
MascotStage oshiStageFor({
  required int distinctAnswered,
  required int totalQuestions,
  required int correct,
}) {
  if (totalQuestions <= 0 || distinctAnswered <= 0) return MascotStage.lv1;
  final coverage = (distinctAnswered / totalQuestions).clamp(0.0, 1.0);
  final accuracy = (correct / distinctAnswered).clamp(0.0, 1.0);
  return MasteryModel.standard
      .stageOf(MasteryInput(coverage: coverage, accuracy: accuracy));
}

const _kDisplayKey = 'ukalab_g_kentei_oshi_display';

/// 推しの表示設定（通常／小さく／非表示）。端末内に保存する。
class OshiDisplayNotifier extends Notifier<MascotDisplay> {
  @override
  MascotDisplay build() {
    _load();
    return MascotDisplay.normal;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kDisplayKey);
    if (v == null) return;
    state = MascotDisplay.values.firstWhere(
      (e) => e.name == v,
      orElse: () => MascotDisplay.normal,
    );
  }

  Future<void> set(MascotDisplay d) async {
    state = d;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDisplayKey, d.name);
  }
}

final oshiDisplayProvider =
    NotifierProvider<OshiDisplayNotifier, MascotDisplay>(OshiDisplayNotifier.new);

/// ホームの「推し」カード。学習が進むと成長し、状況に合ったひとことを話す。
/// タップでひとことが変わる。メニューから小さく／非表示にできる。
class OshiCard extends ConsumerStatefulWidget {
  const OshiCard({super.key, required this.totalQuestions, this.examDate});

  /// 出題範囲の全問題数（網羅率の分母）。
  final int totalQuestions;

  /// 試験日（設定した人だけ）。
  final DateTime? examDate;

  @override
  ConsumerState<OshiCard> createState() => _OshiCardState();
}

class _OshiCardState extends ConsumerState<OshiCard> {
  int _seed = 0;

  @override
  Widget build(BuildContext context) {
    final display = ref.watch(oshiDisplayProvider);
    final theme = Theme.of(context);
    final coin = ref.watch(coinProvider);
    final now = DateTime.now();
    final examPhase = MascotDayState(examDate: widget.examDate).examPhase(now);
    // PopupMenuButton は showMenu の戻り値が null だと「キャンセル」と区別できず
    // onSelected を呼ばないため、value は null にできない。文字列で表す。
    final menu = PopupMenuButton<String>(
      tooltip: '推しの表示',
      icon: const Icon(Icons.more_vert),
      onSelected: (v) {
        if (v == 'wardrobe') {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => OshiWardrobeView(examPhase: examPhase),
          ));
          return;
        }
        final d = MascotDisplay.values.firstWhere((e) => e.name == v);
        ref.read(oshiDisplayProvider.notifier).set(d);
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'wardrobe', child: Text('着替え・ショップ')),
        PopupMenuItem(value: 'normal', child: Text('通常')),
        PopupMenuItem(value: 'small', child: Text('小さく表示')),
        PopupMenuItem(value: 'hidden', child: Text('表示しない')),
      ],
    );

    if (display == MascotDisplay.hidden) {
      return Card(
        child: ListTile(
          title: Text('学習コイン ${coin.balance}', style: theme.textTheme.labelLarge),
          subtitle: const Text('推しは非表示です'),
          trailing: menu,
        ),
      );
    }

    final progress = ref.watch(progressProvider);
    final stage = oshiStageFor(
      distinctAnswered: progress.distinctAnswered,
      totalQuestions: widget.totalQuestions,
      correct: progress.correctCount,
    );
    // 連続学習日数・最終学習日は後続（間隔反復・学習記録）で対応するため、
    // 現時点では常に「未設定」として扱う。
    final day = MascotDayState(examDate: widget.examDate);
    final situation = switch (examPhase) {
      ExamPhase.today => MascotSituation.examToday,
      ExamPhase.eve => MascotSituation.examEve,
      ExamPhase.close => MascotSituation.examClose,
      ExamPhase.approaching => MascotSituation.examApproaching,
      ExamPhase.none => MascotSituation.greeting,
    };
    final line = MascotLines.gentle.pick(situation, seed: _seed);
    final small = display == MascotDisplay.small;
    final equipped = ref.watch(equippedOutfitProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Row(
          children: [
            MascotWidget(
              stage: stage,
              outfit: equipped,
              expression: day.expression,
              examPhase: examPhase,
              display: display,
              size: small ? 56 : 88,
              line: small ? null : line,
              onTap: () => setState(() => _seed++),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('あなたの推し  Lv${stage.level}', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    small ? line : '推しをタップすると、ひとこと話します',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text('学習コイン ${coin.balance}', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            menu,
          ],
        ),
      ),
    );
  }
}
