# うかラボ G検定

JDLA Deep Learning for GENERAL（G検定）対策アプリ。**JDLAとは無関係の非公式アプリ**です。

## 位置づけ

```
うかラボ G検定（本リポジトリ） → yourwish_kentei（検定エンジン） → app_common_kit（共通基盤）
```

このリポジトリは、**ExamConfig（試験定義）・問題データ・テーマ設定・ストア設定**だけを持つ薄いリポジトリです。
出題・採点・間隔反復などのロジックは [yourwish_kentei](https://github.com/zka32101/yourwish_kentei)、
共通UI・推し・コイン・課金・広告は [app_common_kit](https://github.com/zka32101/app_common_kit) に置きます。
両方とも `ref: vX.Y.Z` のタグ固定で参照します（`main` は参照しません）。

## 構成

```
assets/
  exam/g_kentei.json        ExamConfig（公式10項目を章立てに採用）
  questions/g_kentei.jsonl  問題データ（JSON Lines）。現在は初期サンプル40問
lib/
  data/exam_repository.dart  assets から ExamConfig・問題を読み込む
  screens/                   ホーム／学ぶ／模擬／記録／設定
  main.dart
```

## 開発

```bash
flutter pub get
flutter analyze
flutter test
```

問題データの検証（配信前・CI）:

```bash
dart run yourwish_kentei:validate_content assets/exam/g_kentei.json assets/questions/g_kentei.jsonl
```

## 現状・未完了（2026-10-02 時点）

- 問題データは初期サンプル40問のみ。目標は約600問（公式の出題内容10項目：人工知能とは／人工知能をめぐる動向／機械学習の概要／ディープラーニングの概要／要素技術／応用例／AIの社会実装／数理・統計知識／AIに関する法律と契約／AI倫理・AIガバナンス）。追加分は**運営者確認・出典の裏取りが必須**。
- 用語カード（決定50）、推し・コイン・衣装、課金（RevenueCat）・広告（AdMob）、Firebase連携、学習体験の「型」①〜④（境界線スライダー・予測→実行・推しの答案を添削・最短ルートプランナー）は未実装。
- 詳細設計は Google Drive の `design/kentei-engine（うかラボ）` フォルダの企画設計書・決定事項ログを参照。
