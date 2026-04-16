---
name: phase-6-build
description: フェーズ6。spec.md に基づいて実際に動くプロトタイプを生成する。種別(web-app/gpts/claude-skill/harness/bot)に応じた成果物を出力する。
---

# Phase 6: プロトタイプ実装

## 入力
- `projects/<slug>/phase-5-spec.md`

## 共通ルール

- `mkdir -p projects/<slug>/prototype` を最初に実行
- 成果物はすべて `projects/<slug>/prototype/` 配下に出力
- `projects/<slug>/decisions.md` に選定理由を記録
- 検証(種別ごと)に失敗した場合、最大3回まで自己修復

## 種別ごとの処理

spec.md の `prototype_type` を読み、対応するセクションの手順に従う。

---

### web-app

#### 1. テンプレ選定
spec.md の「解決手段」と問題タイプから `templates/` 配下の最適なテンプレを1つ選ぶ。

| 用途 | テンプレ |
|---|---|
| LP / 紹介サイト | landing-page |
| 問い合わせ・申込 | form-app |
| AI チャット | chatbot |
| 業務ダッシュボード | dashboard |
| 予約 | booking |
| 作品掲載 | portfolio |

#### 2. コピー
`templates/<選定>/index.html` を `projects/<slug>/prototype/index.html` にコピー。

#### 3. デルタ編集
spec.md の値で差分のみ編集:
- タイトル/見出し
- 入出力項目
- ダミーデータ
- 配色(`design-system` を参照)
- 外部APIブロック(必要なら)

**ゼロから書かない**。テンプレ構造を壊さない。

#### 4. 外部API埋め込み(必要時)
spec.md の `external_api` がある場合、固定パターンで埋め込む:

```html
<script>
  const MOCK = /* spec の mock を埋め込む */;
  const USE_REAL = /* auth==="none" なら true */;
  const ENDPOINT = /* spec の endpoint */;

  async function loadData() {
    if (!USE_REAL) return MOCK;
    try {
      const r = await fetch(ENDPOINT);
      if (!r.ok) throw new Error();
      return await r.json();
    } catch { return MOCK; }
  }
  loadData().then(render);
</script>
```

**APIキーは絶対に HTML に書かない**。`auth: key` の場合は MOCK のみ使う。

#### 5. 検証
`scripts/verify.sh projects/<slug>/prototype` を実行。**この検証は web-app 種別のみ**。

#### ゲートチェック
- [ ] `projects/<slug>/prototype/index.html` が存在
- [ ] verify.sh が PASS(警告のみ可)
- [ ] テンプレ外の任意CDN や eval が無い
- [ ] APIキーが HTML 内にハードコードされていない

---

### gpts

#### 1. GPTs 設定ファイル生成
`projects/<slug>/prototype/gpts-config.json` を生成:

```json
{
  "name": "<GPTs名>",
  "description": "<一行説明>",
  "instructions": "→ instructions.md を参照",
  "conversation_starters": [
    "<開始プロンプト1>",
    "<開始プロンプト2>",
    "<開始プロンプト3>"
  ],
  "capabilities": {
    "web_browsing": false,
    "code_interpreter": false,
    "dall_e": false
  },
  "actions": [],
  "knowledge_files": []
}
```

#### 2. システムプロンプト生成
`projects/<slug>/prototype/instructions.md` を生成:
- 役割定義(誰として振る舞うか)
- 対応範囲(何に答えて、何に答えないか)
- 出力フォーマット(箇条書き/表/段落)
- 禁止事項(ハルシネーション防止ルール等)
- spec.md の入出力定義を反映

#### 3. Actions 定義(必要時)
外部連携がある場合、`projects/<slug>/prototype/actions-schema.json` に OpenAPI スキーマの mock を生成。

#### 4. Knowledge ファイル(必要時)
参照データがある場合、`projects/<slug>/prototype/knowledge/` にサンプルファイルを配置。

#### 5. テスト会話ログ
`projects/<slug>/prototype/test-conversations.md` に3シナリオ以上の想定会話を記録。

#### ゲートチェック
- [ ] `gpts-config.json` が存在し、必須フィールドが埋まっている
- [ ] `instructions.md` が存在し、役割・対応範囲・禁止事項が定義されている
- [ ] `test-conversations.md` に3シナリオ以上の会話例がある
- [ ] conversation_starters が3つ以上ある

---

### claude-skill

#### 1. skill ディレクトリ構成
```
projects/<slug>/prototype/
├── .claude/
│   └── skills/
│       └── <skill-name>/
│           └── SKILL.md
├── README.md          # 使い方の説明
└── example-input.md   # サンプル入力
```

#### 2. SKILL.md 生成
spec.md の入出力定義を元に SKILL.md を生成:
- name / description(frontmatter)
- 入力(何を受け取るか)
- 処理手順(ステップバイステップ)
- 出力(何を生成するか)
- ゲートチェック(品質基準)

#### 3. サブ skill(必要時)
複数 skill チェーンの場合、各 skill を個別に生成。

#### 4. サンプル実行
`example-input.md` を入力として、skill が生成するであろう出力のサンプルを `projects/<slug>/prototype/example-output.md` に生成。

#### ゲートチェック
- [ ] `SKILL.md` が存在し、frontmatter が正しい
- [ ] 入力・処理手順・出力・ゲートチェックの4セクションがある
- [ ] `example-input.md` と `example-output.md` が存在
- [ ] README.md に使い方が書かれている

---

### harness

#### 1. ハーネス構成
```
projects/<slug>/prototype/
├── CLAUDE.md              # 司令塔ルール
├── .claude/
│   ├── skills/
│   │   ├── <phase-name>/SKILL.md  # 各フェーズ
│   │   └── ...
│   └── settings.json      # 権限・フック
├── README.md              # 使い方
└── templates/             # 必要に応じて
```

#### 2. CLAUDE.md 生成
- ハーネスの目的・対象ユーザー
- フェーズ一覧(テーブル)
- 絶対ルール
- 各フェーズの成果物定義

#### 3. 各フェーズ skill 生成
spec.md のシナリオ・入出力を元に、各フェーズの SKILL.md を生成:
- 入力 / 処理手順 / 出力 / ゲートチェック

#### 4. settings.json 生成
- 書き込み先のホワイトリスト
- 危険コマンドのブロックフック

#### ゲートチェック
- [ ] `CLAUDE.md` が存在し、フェーズ一覧がある
- [ ] 各フェーズの `SKILL.md` が存在し、ゲートチェックがある
- [ ] `settings.json` に権限設定がある
- [ ] README.md に使い方が書かれている

---

### bot

#### 1. Bot 仕様書
`projects/<slug>/prototype/bot-spec.md` を生成:
- Bot の役割・性格
- 対応チャネル(Slack/LINE/Teams 等)
- 対話フロー(状態遷移図またはフローチャート)
- コマンド一覧(あれば)
- エラー応答パターン

#### 2. サンプル会話ログ
`projects/<slug>/prototype/conversations/` に最低3シナリオ:
- `scenario-1-happy-path.md` — 正常系
- `scenario-2-edge-case.md` — 境界ケース
- `scenario-3-error.md` — エラー系

各シナリオは `ユーザー:` / `Bot:` の対話形式で記述。

#### 3. 外部連携定義(必要時)
`projects/<slug>/prototype/integrations.md` に連携先 API の mock 定義。

#### ゲートチェック
- [ ] `bot-spec.md` が存在し、対話フローが定義されている
- [ ] 3シナリオ以上の会話ログがある
- [ ] 正常系・エラー系の両方がカバーされている

---

## 共通: decisions.md に記録

すべての種別で、このフェーズで選んだもの全てを `projects/<slug>/decisions.md` に追記:

```markdown
## Phase 6 (<ISO8601>)
- プロトタイプ種別: <種別>
- 選定構成: <詳細>
- 自己修復回数: <0-3>
- 成果物一覧: <ファイルリスト>
```

## STATUS.md 更新
ゲート通過後に `projects/<slug>/STATUS.md` を更新:
- Phase 6 → `completed` + 完了日時 + 成果物パス
- LLM を使う場合: Phase 7 → `in_progress`
- LLM を使わない場合: Phase 7 → `skipped`、「次のアクション」を `商談実施後に検証結果を伝えてください` に
- Phase 8 が商談待ちの場合: 「現在のフェーズ」を `Phase 8: ユーザー検証 — waiting_for_meeting` に

## 次フェーズ
`phase-7-prompt-tuning` skill へ(LLM を使う場合のみ。使わない場合は phase-8 へスキップ可)。

## 反復修正

商談後にユーザーが修正依頼してきた場合は、新しい spec を作らずこのフェーズだけ再実行する。
