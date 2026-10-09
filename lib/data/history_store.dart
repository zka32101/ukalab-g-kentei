import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 解答履歴の保存件数の上限。古いものから捨てる（端末内の保存サイズを抑える）。
const historyMaxRecords = 2000;

/// 1問ごとの解答履歴（[ProgressRecord]）を端末内に保存する。
///
/// 弱点ドリル・試験直前・履歴CSVの元データ。個人を特定する情報は持たない。
class HistoryNotifier extends Notifier<List<ProgressRecord>> {
  static const _key = 'ukalab_g_kentei_history_v1';

  late Future<void> _loaded;

  @override
  List<ProgressRecord> build() {
    _loaded = _load();
    return const [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final records = list.map(ProgressRecord.fromJson).whereType<ProgressRecord>().toList();
      // 読み込み中に追加された分を失わないよう、先頭に足す。
      state = [...records, ...state];
    } catch (_) {
      // 壊れた保存データは無視して空から始める。
    }
  }

  /// 解答を1件記録する。[ms] は回答にかかった時間（ミリ秒、不明なら省略）。
  Future<void> record(
    Question q, {
    required bool correct,
    int? ms,
    DateTime? at,
  }) async {
    await _loaded;
    final next = [
      ...state,
      ProgressRecord(
        qid: q.qid,
        subjectId: q.subjectId,
        correct: correct,
        at: at ?? DateTime.now(),
        topicId: q.topicId,
        subtopicId: q.subtopicId,
        ms: ms,
      ),
    ];
    state = next.length > historyMaxRecords
        ? next.sublist(next.length - historyMaxRecords)
        : next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode([for (final r in state) r.toJson()]));
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<ProgressRecord>>(HistoryNotifier.new);

/// 履歴CSV（日付ごと＋分野ごと）。個人情報は含まない。
String historyCsv(List<ProgressRecord> records, List<Question> questions) {
  final daily = dailySummaryCsv(summarizeByDay(records));
  final topics = topicAccuracyCsv(summarizeByTopic(records, questions: questions));
  return '$daily\n$topics';
}
