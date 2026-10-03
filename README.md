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
  questions/g_kentei.jsonl  問題データ（JSON Lines）。600問（企画設計書§4の目標配分どおり）
  terms/g_kentei.jsonl      用語データ（決定50）。初期サンプル50語。目標は約400語
lib/
  data/exam_repository.dart  assets から ExamConfig・問題・用語を読み込む
  screens/                   ホーム／学ぶ／模擬／記録／設定／用語集
  main.dart
```

## 開発

```bash
flutter pub get
flutter analyze
flutter test
```

問題・用語データの検証（配信前・CI）:

```bash
dart run yourwish_kentei:validate_content assets/exam/g_kentei.json --terms assets/terms/g_kentei.jsonl assets/questions/g_kentei.jsonl
```

## 現状・未完了（2026-10-03 時点）

- 問題データは600問（企画設計書§4の目標配分どおり）。
- 用語カード（決定50）は初期実装済み（用語データ50語、ホーム画面から「用語集」で検索・閲覧、用語カードはボトムシートで開き関連用語をタップで移動）。目標は約400語で、追加分は**運営者確認・出典の裏取りが必須**。問題文・解説文中の用語への下線＋タップ組み込み（`TappableTermText`）は、`app_common_kit` の `QuestionCard.textWidget`/`ExplanationPanel.bodyWidget` が使えるタグに更新した後に対応予定。
- 推し・コイン・衣装、課金（RevenueCat）・広告（AdMob）、Firebase連携、学習体験の「型」①〜④（境界線スライダー・予測→実行・推しの答案を添削・最短ルートプランナー）は未実装。
- 詳細設計は Google Drive の `design/kentei-engine（うかラボ）` フォルダの企画設計書・決定事項ログを参照。
