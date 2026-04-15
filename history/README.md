# Generation History

このフォルダには過去に生成したプロトタイプの履歴が記録されます。

## ファイル

- `index.jsonl` — 全生成履歴の追記ログ（1行1エントリ）

## エントリ形式

```json
{"id":"20260415-143022","project_name":"mycafe","template":"landing-page","title":"My Cafe","purpose":"landing","style":"minimal","spec_path":"specs/20260415-143022-spec.yaml","output_path":"output/mycafe","created_at":"2026-04-15T14:30:22+09:00","summary":"カフェのLP"}
```

## 再利用

ユーザーが「前回のカフェをベースにパン屋さんを作って」のように言った場合、
`history-reuse` スキルが `index.jsonl` を検索し、該当エントリの `output_path` をベースにして
新しいプロジェクトを生成します。
