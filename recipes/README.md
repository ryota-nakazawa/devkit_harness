# recipes/

**確定レシピ集**。複数案件で再現性が確認された "こう作ったら上手くいった" パターンを保管する場所。

## レシピ昇格ルール

`learnings/` に貯まった単発の学びが **同じパターンで2回以上再現** したら、ここに昇格する。
昇格は `phase-9-improvement-planning` skill が候補を検出して提案する。

## ディレクトリ構造

```
recipes/
├── <recipe-tag>/
│   ├── recipe.md          # 問題タイプ / 刺さったポイント / 外したポイント / 適用条件
│   ├── spec-template.yaml # 次回流用できる spec 雛形
│   └── snippets/          # 流用可能な HTML/JS/プロンプト断片
```

## recipe.md フォーマット

```markdown
---
tag: <recipe-tag>
domain: <業界カテゴリ>
times_used: <整数>
success_rate: <成功/試行>
created_at: <ISO8601>
updated_at: <ISO8601>
---

## 問題タイプ
このレシピが当てはまる案件の特徴。

## 刺さった構成
- 何を選んだか、なぜ良かったか

## 外したこと
- やってみてダメだった選択(避けるべきこと)

## 適用条件
- このレシピを使って良い案件の見極めポイント

## 流用ブロック
- snippets/<file> の説明

## 改善メモ
- 次回試したいこと
```

## 検索

`phase-2-solution-selection` skill が新規案件の問題タイプから関連レシピを検索し、候補として提示する。
