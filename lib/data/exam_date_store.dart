import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 利用者が入力した受験日の端末内保存。未設定なら null。
/// 優先順位と保存形式は ukalab_core（[effectiveExamDates] など）。
class ExamDateStore {
  ExamDateStore(this.appId);

  final String appId;

  String get _key => '${appId}_exam_date';

  Future<DateTime?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return decodeExamDate(prefs.getString(_key));
  }

  Future<void> write(DateTime? date) async {
    final prefs = await SharedPreferences.getInstance();
    if (date == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, encodeExamDate(date));
    }
  }
}

/// 保存先。`main()` で `ExamDateStore('アプリID')` に差し替える。
final examDateStoreProvider = Provider<ExamDateStore>((ref) => ExamDateStore('app'));

/// 受験日（利用者入力）。`load()` で保存値を読み込み、`setDate(null)` で解除する。
class ExamDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  Future<void> load() async {
    state = await ref.read(examDateStoreProvider).read();
  }

  Future<void> setDate(DateTime? date) async {
    state = date == null ? null : DateTime(date.year, date.month, date.day);
    await ref.read(examDateStoreProvider).write(date);
  }
}

final examDateProvider = NotifierProvider<ExamDateNotifier, DateTime?>(ExamDateNotifier.new);
