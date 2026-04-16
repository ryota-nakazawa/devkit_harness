---
name: phase-9-improvement-planning
description: フェーズ9。検証結果から次の改善方針を整理し、learnings/ への記録と recipes/ への昇格判定を行う。
---

# Phase 9: 改善方針整理

## 入力
- `projects/<slug>/phase-8-validation.md`
- `projects/<slug>/phase-1-requirements.md`(初期assumption の参照)
- 既存の `learnings/` と `recipes/`

## 役割

このフェーズは **2つの仕事** を持つ:

1. **案件内**: 次のスプリントに渡す改善方針を作る
2. **案件横断**: 学びを `learnings/` に記録し、`recipes/` 昇格を判定する

これを切り離さないこと。後者を省くと案件間でナレッジが貯まらない。

## 処理手順

### 1. 改善案の整理
phase-8 の「次回までに必要な変更」を優先度付きで整理:

| 優先 | 項目 | 種別 | 工数感 |
|---|---|---|---|
| P0 | ... | バグ | <時間> |
| P1 | ... | 機能追加 | ... |
| P2 | ... | 改善 | ... |

### 2. 残課題と次アクション
- 残っている TBD
- 次の商談で確認すべき項目
- 開発者(ユーザー自身)への申し送り

### 3. learnings/ 草稿生成
このフェーズの**最重要パート**。`learnings/<YYYYMMDD-HHMMSS>-<slug>.md` を生成する。

phase-8 の「想定外の反応」「assumption 検証」「不足機能」を元に:
- **刺さったこと**(成功要因)
- **外したこと**(失敗要因 — "特になし"でも明記)
- **次回試したいこと**

を抽出。書式は `learnings/README.md` 参照。

### 4. recipes/ 昇格判定
既存の `learnings/` を全件読み込み、今回の learning と**同じパターンが2回以上**現れているか確認。

該当する場合は **昇格候補** としてユーザーに提示:
```
🎯 昇格候補を発見しました

learnings/ 内に "週カレンダー表示が予約系で刺さる" パターンが3回(本件含む)現れています。
recipes/booking-week-calendar/ として昇格しますか? [y/n]
```

ユーザーが y なら `recipes/<tag>/` を新規作成し、関連 learnings の `status: draft` を `promoted` に更新。

### 5. 出力

`projects/<slug>/phase-9-next.md`:

```markdown
---
project: <slug>
phase: 9
created_at: <ISO8601>
sprint_ready: true | false
---

# Phase 9: 改善方針

## 改善案(優先度順)
| 優先 | 項目 | 種別 | 工数感 |
|---|---|---|---|
| ... | ... | ... | ... |

## 残課題
- ...

## 次アクション
- 次商談までに: ...
- 開発側で: ...

## 学びの記録
- learnings/<file>.md に保存済み
- 昇格候補: <あり/なし>
- 昇格対象: recipes/<tag>/(あれば)
```

## ゲートチェック
- [ ] 改善案が優先度付きで整理されている
- [ ] learnings/<file>.md が生成されている
- [ ] 昇格判定が実行されている(該当なしでも明記)
- [ ] sprint_ready が true なら次スプリントに渡せる状態

## STATUS.md 更新
ゲート通過後に `projects/<slug>/STATUS.md` を更新:
- Phase 9 → `completed` + 完了日時 + 成果物パス
- 全フェーズが `completed`(または `skipped`)であることを確認
- 「現在のフェーズ」を `全フェーズ完了` に
- 「次のアクション」を `v2 が必要なら phase-1 の TBD 更新から再開` に

## 案件完了

このフェーズが完了した時点で、案件は1サイクル終了。
新規案件なら phase-1 から、同じ案件の v2 なら phase-1 の TBD 更新から再開する。
