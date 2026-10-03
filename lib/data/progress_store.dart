import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 推し（マスコット）の成長段階を計算するための、軽量な学習進捗。
///
/// qid ごとに最新の正誤だけを保持する（履歴は持たない）。苦手分析・間隔反復
/// などの本格的な学習記録は後続で別途用意する。[mockPassedEver] は
/// 「準備完了」の判定（決定67〜77、`ReadinessRule`）に使う。
class ProgressState {
  const ProgressState({
    this.answeredQidToCorrect = const {},
    this.mockPassedEver = false,
  });

  final Map<String, bool> answeredQidToCorrect;

  /// 模擬試験で合格点を一度でも超えたか。
  final bool mockPassedEver;

  int get distinctAnswered => answeredQidToCorrect.length;
  int get correctCount => answeredQidToCorrect.values.where((c) => c).length;
}

class ProgressNotifier extends Notifier<ProgressState> {
  static const _key = 'ukalab_g_kentei_progress_v1';
  static const _mockPassedKey = 'ukalab_g_kentei_mock_passed_ever_v1';

  @override
  ProgressState build() {
    _load();
    return const ProgressState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final mockPassedEver = prefs.getBool(_mockPassedKey) ?? false;
    if (raw == null) {
      state = ProgressState(mockPassedEver: mockPassedEver);
      return;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = ProgressState(
        answeredQidToCorrect: decoded.map((k, v) => MapEntry(k, v as bool)),
        mockPassedEver: mockPassedEver,
      );
    } catch (_) {
      // 壊れた保存データは無視して空の状態から始める。
      state = ProgressState(mockPassedEver: mockPassedEver);
    }
  }

  Future<void> recordAnswer(String qid, {required bool correct}) async {
    state = ProgressState(
      answeredQidToCorrect: {...state.answeredQidToCorrect, qid: correct},
      mockPassedEver: state.mockPassedEver,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.answeredQidToCorrect));
  }

  /// 模擬試験の結果を記録する。[passed] が true なら [mockPassedEver] を立てる
  /// （一度立てば下がらない）。
  Future<void> recordMockResult({required bool passed}) async {
    if (!passed || state.mockPassedEver) return;
    state = ProgressState(
      answeredQidToCorrect: state.answeredQidToCorrect,
      mockPassedEver: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mockPassedKey, true);
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);
