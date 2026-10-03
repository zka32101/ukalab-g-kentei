import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 推し（マスコット）の成長段階を計算するための、軽量な学習進捗。
///
/// qid ごとに最新の正誤だけを保持する（履歴は持たない）。苦手分析・間隔反復
/// などの本格的な学習記録は後続で別途用意する。
class ProgressState {
  const ProgressState({this.answeredQidToCorrect = const {}});

  final Map<String, bool> answeredQidToCorrect;

  int get distinctAnswered => answeredQidToCorrect.length;
  int get correctCount => answeredQidToCorrect.values.where((c) => c).length;
}

class ProgressNotifier extends Notifier<ProgressState> {
  static const _key = 'ukalab_g_kentei_progress_v1';

  @override
  ProgressState build() {
    _load();
    return const ProgressState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = ProgressState(
        answeredQidToCorrect: decoded.map((k, v) => MapEntry(k, v as bool)),
      );
    } catch (_) {
      // 壊れた保存データは無視して空の状態から始める。
    }
  }

  Future<void> recordAnswer(String qid, {required bool correct}) async {
    state = ProgressState(
      answeredQidToCorrect: {...state.answeredQidToCorrect, qid: correct},
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.answeredQidToCorrect));
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);
