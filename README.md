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
  terms/g_kentei.jsonl      用語データ（決定50）。399語（目標約400語をほぼ達成）
lib/
  data/exam_repository.dart  assets から ExamConfig・問題・用語を読み込む
  data/progress_store.dart   推しの成長段階を出すための軽量な学習進捗（端末内保存）
  widgets/oshi_card.dart     ホームの「推し」カード（MascotWidget・学習コイン残高）
  widgets/oshi_wardrobe.dart 衣装の着替え・ショップ画面
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
- 用語カード（決定50）は実装済み（用語データ399語、ホーム画面から「用語集」で検索・閲覧、用語カードはボトムシートで開き関連用語をタップで移動、問題文・解説文中の用語には下線＋タップで用語カードが開く）。**追加・修正分は運営者確認・出典の裏取りが必須**。
- 推し・学習コイン・衣装は実装済み（ホーム画面に「推し」カード。「学ぶ」タブで新しい問題に解答するとコイン+1、網羅率×正答率で推しがLv1〜5に成長。メニューの「着替え・ショップ」から通常衣装をコイン購入・着用できる）。合格記念・試験日の装い・準備完了の装いは、合格報告・模擬試験・最短ルートプランナーが未実装のため条件を満たせない。連続学習日数・模擬試験でのコイン付与は未実装（決定67〜77参照、学習記録機能の整備後に対応）。
- 課金（RevenueCat）・広告（AdMob）、Firebase連携、学習体験の「型」①〜④（境界線スライダー・予測→実行・推しの答案を添削・最短ルートプランナー）は未実装。
- 詳細設計は Google Drive の `design/kentei-engine（うかラボ）` フォルダの企画設計書・決定事項ログを参照。
