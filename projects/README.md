# projects/

各案件ごとのフェーズ成果物を1ディレクトリにまとめる場所。

## 構造

```
projects/<project-slug>/
├── phase-1-requirements.md   # ヒアリング結果
├── phase-2-solutions.md      # 解決手段の比較と選定
├── phase-3-scenarios.md      # 利用シーン
├── phase-4-io.md             # 入出力定義
├── phase-5-spec.md           # 要件定義書(1〜4の統合)
├── prototype/                # フェーズ6: 実装(HTML 等)
│   └── index.html
├── phase-7-prompts/          # フェーズ7: プロンプト改善履歴
│   ├── v1.md
│   └── v2.md
├── phase-8-validation.md     # フェーズ8: ユーザー検証結果
├── phase-9-next.md           # フェーズ9: 改善方針
└── decisions.md              # 各フェーズで Claude が記録した選定理由(横串)
```

## ルール

- **1案件 = 1ディレクトリ**。途中の成果物も最終成果物も全部ここに集約
- ファイル命名は固定(上記)。`history-reuse` や `recipes` の昇格ロジックがこの命名を前提に動く
- 案件名(slug)は英数字・ハイフンのみ、できれば業界 + 用途で(例: `cafe-booking`, `clinic-reservation`)
- このディレクトリは `.gitignore` 対象(ナレッジは `recipes/` `learnings/` に昇格させる)
