---
name: phase-5-requirements-doc
description: フェーズ5。phase-1〜4 を統合して正式な要件定義書(spec.md)を生成する。
---

# Phase 5: 要件定義書化

## 入力
- `projects/<slug>/phase-1-requirements.md`
- `projects/<slug>/phase-2-solutions.md`
- `projects/<slug>/phase-3-scenarios.md`
- `projects/<slug>/phase-4-io.md`

## 役割

このフェーズは **新しい情報を作らない**。1〜4で出た成果物を統合して、実装フェーズが参照する単一のソース(spec.md)を作る。

## 処理手順

### 1. 統合
4つのファイルから必要セクションを抽出して1つの spec.md にまとめる。重複は削る、矛盾があればフラグを立てる。

### 2. 矛盾チェック
phase-1 の制約 と phase-4 の入出力が矛盾していないか機械的に確認:
- phase-1 で「データ保存しない」と書いてあるのに phase-4 で保存先がある → 警告
- phase-3 のシナリオに登場する操作が phase-4 の入出力に無い → 警告
- TBD のままの項目が実装に影響する → 警告

### 3. 実装前提を固める
spec.md の末尾に「実装フェーズが守るべき前提」を箇条書きで残す。

## 出力

`projects/<slug>/phase-5-spec.md`:

```markdown
---
project: <slug>
phase: 5
created_at: <ISO8601>
prototype_type: <phase-2 の種別>
solution: <phase-2 の選定>
---

# 要件定義書

## 1. 目的
<phase-1 の背景・期待効果から>

## 2. 対象業務
<phase-1 の現状業務・課題から>

## 3. 利用者
<phase-1 の利用者像 + phase-3 の役割分担>

## 4. 利用シーン
<phase-3 から>

## 5. 入出力
<phase-4 から>

## 6. 解決手段
<phase-2 の選定結果(種別 + 候補)>

## 7. PoC 成立条件
<phase-3 から>

## 8. 制約
<phase-1 から>

## 9. 未確定事項
<phase-1 の TBD で未解決のもの>

## 10. 実装前提
<種別に応じて記載>

### web-app の場合
- 静的 HTML + Tailwind CDN
- キー必須API は mock のみ
- ダミーデータは <件数> 件

### gpts の場合
- GPTs 設定 JSON + システムプロンプト
- Actions は mock エンドポイントで定義
- Knowledge ファイルがあればサンプルを用意

### claude-skill の場合
- SKILL.md + 必要に応じてサブファイル
- 外部連携は MCP サーバー定義で表現

### harness の場合
- CLAUDE.md + skills/ ディレクトリ一式
- settings.json(権限・フック)
- 各フェーズにゲートチェック

### bot の場合
- Bot 仕様書(対話フロー定義)
- サンプル会話ログ(3シナリオ以上)
- 外部API連携は mock 定義

- スコープ外: <列挙>

## 11. 矛盾警告
- なし / または検出した警告
```

## ゲートチェック
- [ ] 11 セクション全て埋まっている
- [ ] 矛盾警告セクションがある(なければ "なし" と明記)
- [ ] TBD で未解決のものが明示されている
- [ ] 実装前提が箇条書きで存在

## STATUS.md 更新
ゲート通過後に `projects/<slug>/STATUS.md` を更新:
- Phase 5 → `completed` + 完了日時 + 成果物パス
- Phase 6 → `in_progress`
- 「次のアクション」を Phase 6 の内容に更新

## 次フェーズ
`phase-6-build` skill へ。
