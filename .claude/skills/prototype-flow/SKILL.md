---
name: prototype-flow
description: 9フェーズ・プロトタイプワークフローのオーケストレーター。「次の商談用にプロト作って」「この要件をもとにプロトを準備して」などの依頼で起動する。各フェーズは独立 skill として実装されており、ゲートチェックを満たさない限り次に進めない。
---

# Prototype Flow (9-Phase Orchestrator)

## 起動条件

ユーザーから以下のような依頼があったとき:
- 「次の商談用にプロト作って」
- 「この要件をもとに準備して」
- 「○○のプロト作りたい」「試作したい」
- 客の議事録/メール/Slack を貼り付けられた

## 設計思想

このハーネスの目的は **「誰がやっても同じ水準のプロトタイプが出る」** こと。
そのために9フェーズに分割し、**各フェーズに成果物ゲート**を置いている。
スピードはフェーズを飛ばすのではなく、**Claude が下書きを作ってユーザーは承認するだけ**で実現する。

## フェーズ一覧

| # | フェーズ | skill | 成果物 |
|---|---|---|---|
| 1 | ヒアリング | `phase-1-hearing` | `phase-1-requirements.md` |
| 2 | 解決手段の選定 | `phase-2-solution-selection` | `phase-2-solutions.md` |
| 3 | 利用イメージ整理 | `phase-3-usage-scenarios` | `phase-3-scenarios.md` |
| 4 | 入出力整理 | `phase-4-io-mapping` | `phase-4-io.md` |
| 5 | 要件定義書化 | `phase-5-requirements-doc` | `phase-5-spec.md` |
| 6 | プロトタイプ実装 | `phase-6-build` | `prototype/index.html` |
| 7 | プロンプト改善 | `phase-7-prompt-tuning` | `phase-7-prompts/v*.md` |
| 8 | ユーザー検証 | `phase-8-user-validation` | `phase-8-validation.md` |
| 9 | 改善方針整理 | `phase-9-improvement-planning` | `phase-9-next.md` + `learnings/` |

全成果物は `projects/<slug>/` 配下に集約される。

## STATUS.md — 進捗管理(全フェーズ共通)

各フェーズの開始・完了時に `projects/<slug>/STATUS.md` を更新する。
これにより日を跨いだ再開やセッション間の引き継ぎを確実にする。

### フォーマット

```markdown
---
project: <slug>
last_updated: <ISO8601>
---

# 進捗状況

| # | フェーズ | 状態 | 完了日時 | 成果物 |
|---|---|---|---|---|
| 1 | ヒアリング | completed | 2026-04-15T10:00 | phase-1-requirements.md |
| 2 | 解決手段の選定 | in_progress | — | — |
| 3 | 利用イメージ整理 | pending | — | — |
| ... | ... | ... | ... | ... |

## 現在のフェーズ
Phase 2: 解決手段の選定 — in_progress

## 次のアクション
候補3つの比較表をユーザーに提示し、1つ選んでもらう

## 未解決 TBD
- <phase-1 から引き継いだ未解決 TBD を列挙>

## 備考
- <後戻り履歴やスキップ理由があればここに記録>
```

### 更新タイミング

| イベント | STATUS.md の更新内容 |
|---|---|
| フェーズ開始 | 該当行を `in_progress` に、「現在のフェーズ」「次のアクション」を更新 |
| フェーズ完了(ゲート通過) | 該当行を `completed` + 完了日時 + 成果物パス、次フェーズ行を `in_progress` に |
| 後戻り | 備考に理由を記録、戻り先を `in_progress` に |
| 商談待ち(Phase 6→8 の間) | 「次のアクション」を `商談実施後に検証結果を伝えてください` に |

### STATUS.md を最初に作るタイミング

Phase 1 開始時に全9フェーズを `pending` で初期化する。

## 再開・ファシリテーション

### 「続きから」「前の案件の続き」

1. `projects/` 配下の全 `STATUS.md` をスキャン
2. `in_progress` または `completed` だが次が `pending` の案件を特定
3. 該当が1件なら自動で再開、複数ならユーザーに選択肢を提示
4. STATUS.md の「現在のフェーズ」と「次のアクション」を読んで、そこから再開

### 「今どこ？」「進捗は？」

1. 対象 slug を特定(会話文脈 or ユーザーに確認)
2. STATUS.md を読んで以下を報告:

```
📊 案件: <slug>
🔄 現在: Phase <N> — <名前> (<状態>)
✅ 完了済み: Phase 1〜<N-1>
📋 次のアクション: <内容>
⚠️ 未解決 TBD: <N>件
```

### 「案件一覧」

`projects/*/STATUS.md` を全件読み、テーブルで一覧表示:

```
| 案件 | 現在フェーズ | 状態 | 最終更新 |
|---|---|---|---|
| clinic-reservation | Phase 6 | in_progress | 2026-04-15 |
| cafe-membership | Phase 9 | completed | 2026-04-10 |
```

## 実行ルール

### 順序
原則として 1 → 9 の順に実行する。ただし以下は許容:
- フェーズ7はプロトに LLM を使わない場合スキップ可
- フェーズ8〜9 は商談後に実行(時間差が空く)
- フェーズ6で問題が見つかったら2〜5に戻る(後戻りは記録に残す)

### ゲートチェック
各フェーズ完了時に skill 内のゲートチェック項目を全て満たすこと。
満たしていなければ次フェーズに進まず、ユーザーに不足を報告する。

### Claude の役割
- **下書きを作る**: 各フェーズの成果物の80%は Claude が生成
- **TBD を埋めない**: 不明点は推測せず TBD として残す
- **ゲートを守る**: 必須項目が無いまま先に進まない
- **decisions.md に記録**: フェーズ選定理由を `projects/<slug>/decisions.md` に追記

### ユーザーの役割
- 各フェーズ末に Claude が出す成果物をレビューして承認/修正
- TBD のうち客に確認できるものを次商談で確認
- 最終的な選定(候補のうちどれを選ぶか)を決める

## 起動フロー

### 新規案件
1. ユーザーが客の brief を貼り付け or 要件を口頭で伝える
2. `phase-1-hearing` skill を起動
3. ゲート通過 → `phase-2-solution-selection` を起動
4. 以下、フェーズ6まで自動で進める(各フェーズ末に1秒だけユーザー確認を挟む)
5. フェーズ6完了時にプレビュー URL を出す
6. **商談を実施(ユーザーの仕事)**
7. 商談後にユーザーが「検証結果」を伝える → `phase-8-user-validation` を起動
8. `phase-9-improvement-planning` を起動 → 案件1サイクル完了

### 既存案件の v2
1. `projects/<slug>/` が既存の場合、phase-1 の TBD と phase-9 の改善案を読み込む
2. v2 の差分だけヒアリング → phase-2 以降を再実行

## 報告フォーマット

各フェーズ完了時に1〜2行で報告:

```
✅ Phase <N>: <名前> 完了
📂 projects/<slug>/<file>
🔍 主な成果: <一行サマリ>

次フェーズに進みます... (→ Phase <N+1>: <名前>)
```

最終フェーズ(プロト完成)では:

```
✨ プロトタイプ完成 — 次の商談に持っていけます

📂 場所: projects/<slug>/prototype/index.html
👀 プレビュー: open projects/<slug>/prototype/index.html

📋 商談で確認すべき TBD: <N>件
   1. ...
   2. ...

商談後に「検証結果は○○だった」と教えてください。Phase 8 へ進みます。
```

## 禁止事項

1. **フェーズを飛ばす**(ゲートチェックを満たしていない状態で次に進む)
2. **TBD を勝手に推測で埋める**(揉めの元)
3. **`projects/<slug>/` の外に書く**(Phase 9 での `learnings/` 記録と `recipes/` 昇格は例外)
4. **technical 用語をユーザーに見せる**(React/Tailwind/API 等は裏で)
5. **エラー詳細をユーザーに見せる**(自己修復後の結果だけ伝える)
6. **`learnings/` への記録を省く**(長期的な学習サイクルが死ぬ)

## 関連 skill

- `design-system` — フェーズ6の配色・タイポ・余白を統一
- `history-reuse` — フェーズ2で過去レシピを検索する際に呼ばれる
