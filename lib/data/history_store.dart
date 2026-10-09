import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 1問ごとの解答履歴（[ProgressRecord]）を端末内に保存する。
///
/// 弱点ドリル・試験直前・履歴CSVの元データ。個人を特定する情報は持たない。
/// 追記・上限・保存形式は ukalab_core（[appendHistory] など）。ここは端末への保存だけを担う。
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
    final records = decodeHistory(prefs.getString(_key));
    // 読み込み中に追加された分を失わないよう、先頭に足す。
    if (records.isNotEmpty) state = [...records, ...state];
  }

  /// 解答を1件記録する。[ms] は回答にかかった時間（ミリ秒、不明なら省略）。
  Future<void> record(
    Question q, {
    required bool correct,
    int? ms,
    DateTime? at,
  }) async {
    await _loaded;
    state = appendHistory(state, historyRecordFor(q, correct: correct, ms: ms, at: at));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, encodeHistory(state));
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<ProgressRecord>>(HistoryNotifier.new);
