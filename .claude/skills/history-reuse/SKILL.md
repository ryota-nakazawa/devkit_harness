---
name: history-reuse
description: 「前回の○○をベースに」「さっきのやつに似たやつ」「過去の似た案件は?」といった発話で起動する。projects/ と recipes/ の両方を検索し、過去の成果物 + 確定レシピを新案件に流用する。
---

# History Reuse

## 起動条件

- 「前回の○○をベースに」「さっきのやつ」「この前の△△を参考に」
- 「過去の似た案件は?」「同じパターンの案件あった?」
- フェーズ2(解決手段の選定)で `recipes/` 検索を行うときも内部的に呼ばれる

## 検索対象(2系統)

| 系統 | 場所 | 何を持つか | 信頼度 |
|---|---|---|---|
| **projects/** | 個別案件の成果物 | 1案件丸ごと(spec, prototype, validation) | 単発(参考) |
| **recipes/** | 確定レシピ | 複数案件で再現された "成功パターン" | 高(優先) |

**検索順序**: まず `recipes/` を当たり、ヒットが無ければ `projects/` を当たる。
`recipes/` は複数案件の検証を経ているので、単発の `projects/` より優先度が高い。

## 手順

### STEP 1: キーワード抽出
ユーザー発話から以下を抽出:
- 業界(カフェ/医療/SaaS/...)
- 用途(予約/問い合わせ/ダッシュボード/...)
- 特徴的な要件(名前付き/暗黙)

### STEP 2: recipes/ 検索
1. `recipes/<tag>/recipe.md` の frontmatter `domain` と `tag` を全件スキャン
2. キーワードと一致するものを抽出
3. ヒットがあれば `times_used` 降順で並べる

### STEP 3: projects/ 検索(recipes/ で見つからない場合のみ)
1. `projects/*/phase-1-requirements.md` と `phase-5-spec.md` をスキャン
2. キーワードと一致するものを抽出
3. ヒットを `created_at` 降順で並べる

### STEP 4: 提示
1〜3件をユーザーに提示:

```
🔍 過去の参考案件が見つかりました

[recipes/] (確定レシピ)
1. recipes/booking-smb/ — 中小企業向け予約系(3/3成功)

[projects/] (単発案件)
2. projects/clinic-reservation/ — 整体予約 (2026-04-10)
3. projects/cafe-membership/ — カフェ会員管理 (2026-03-22)

どれをベースにしますか? それとも新規にしますか?
```

### STEP 5: 流用方式の選択

**recipes/ から流用する場合**:
- `recipes/<tag>/spec-template.yaml` を新案件の `phase-5-spec.md` の出発点にする
- `recipes/<tag>/snippets/` を `projects/<new>/prototype/` の素材に
- `recipes/<tag>/recipe.md` の「適用条件」「外したこと」を読み込み、Phase 1 のヒアリング時に**注意点として提示**

**projects/ から流用する場合**:
- 元 project の `phase-5-spec.md` を新案件の出発点にする(差分編集)
- 元 project の `prototype/` を `projects/<new>/prototype/` にコピー
- 元の `phase-9-next.md` の「次回試したいこと」を新案件の Phase 1 に反映

### STEP 6: 差分のみ Phase 1 を実行
通常の Phase 1 は brief を貼り付けからだが、流用時は **差分質問のみ**:
- 何が変わるか?
- 何を残すか?
- 元案件で外した点を回避するか?

これらを `phase-1-requirements.md` に追記し、`based_on` フィールドで参照元を記録:

```yaml
---
project: <new-slug>
phase: 1
based_on: recipes/booking-smb | projects/clinic-reservation
created_at: <ISO>
---
```

### STEP 7: phase-2 以降は通常通り
Phase 2 で改めて選定理由を記録(流用元をどう活かすか)、以降通常フローに乗せる。

## 禁止事項

- **元の `projects/<original>/` を上書きしない**(必ず新 slug で複製)
- **`based_on` を省略しない**(系譜が途切れる)
- **`recipes/` を勝手に書き換えない**(昇格は phase-9 の責務)
- **検索ヒットゼロの時に強引に流用しない**(無関係な過去案件を引っ張ると品質が落ちる)

## ヒット0件のとき

何も流用せず、通常の `phase-1-hearing` skill にフォールバックする。
このとき、新規案件として正常に進めれば良い(無理に過去から探さない)。
