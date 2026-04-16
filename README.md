
# devkit_harness — 9フェーズ プロトタイプ準備ハーネス

コンサル/営業が **次の商談までに動くプロトタイプ + 商談補助資料** を準備するための、Claude Code / Codex 用ハーネスです。
客からもらった事前要件(議事録/メール/Slack コピペ)を入力に、**9フェーズの手順**で要件定義 → プロトタイプ → 改善方針までを一気通貫で生成します。

## できること

- 客の事前要件テキストから **構造化要件定義書 + プロトタイプ** を生成
- **5種のプロトタイプ種別**に対応: Web アプリ / GPTs / Claude Code skill / ハーネス設計 / Bot
- **9フェーズ固定フロー**で誰がやっても同じ品質に収束(各フェーズにゲートチェックあり)
- Web アプリの場合は6種の固定テンプレから最適なものを裏で選定(技術名はユーザーに見せない)
- 生成物は種別ごとの自動検証で品質を担保
- エラーは **最大3回の自己修復ループ**で吸収
- 過去の案件 (`projects/`) と昇格済みレシピ (`recipes/`) から **「前回のやつベースで」** の再利用が可能
- **外部API連携**(公開APIは fetch、キー付きAPIは mock データで描画)
- **Claude Code / Codex 両対応**(`CLAUDE.md` / `AGENTS.md` 同等ルール)

## 9フェーズの流れ

| # | フェーズ | 成果物 |
|---|---|---|
| 1 | ヒアリング | `phase-1-requirements.md` |
| 2 | 解決手段の選定 | `phase-2-solutions.md` |
| 3 | 利用イメージ整理 | `phase-3-scenarios.md` |
| 4 | 入出力整理 | `phase-4-io.md` |
| 5 | 要件定義書化 | `phase-5-spec.md` |
| 6 | プロトタイプ実装 | `prototype/`(種別に応じた成果物) |
| 7 | プロンプト改善 | `phase-7-prompts/v*.md` |
| 8 | ユーザー検証 | `phase-8-validation.md` |
| 9 | 改善方針整理 | `phase-9-next.md` + `learnings/` |

全成果物は `projects/<slug>/` 配下に集約されます。

## 対応プロトタイプ種別

| 種別 | 用途 | 成果物 |
|---|---|---|
| Web アプリ | 画面を見せて操作してもらう(予約/フォーム/LP等) | 静的 HTML |
| GPTs | 対話型 AI エージェントのデモ | GPTs 設定 + システムプロンプト |
| Claude Code skill | 業務自動化のデモ | SKILL.md + サンプル入出力 |
| ハーネス設計 | 業務プロセスのハーネス化 | CLAUDE.md + skills 一式 |
| Bot | Slack/LINE/Teams 上のBot | Bot 仕様書 + サンプル会話 |

Web アプリの場合は以下の固定テンプレから選定されます:

| テンプレ | 用途 |
|---|---|
| `landing-page` | お店/サービスの紹介サイト |
| `form-app` | 問い合わせ・申込フォーム |
| `chatbot` | AI チャット風UI |
| `dashboard` | 社内向けデータ表示 |
| `booking` | 予約フォーム |
| `portfolio` | 作品・実績掲載 |

## クイックスタート

### 1. クローン

```bash
git clone https://github.com/ryota-nakazawa/devkit_harness.git
cd devkit_harness
```

### 2. Claude Code を起動

```bash
claude
```

> Codex を使う場合はそのまま `codex` を起動。`AGENTS.md` が読まれます。

### 3. 客の事前要件を貼り付けて依頼する

```
次の商談用にプロト作って。要件はこれ↓
<議事録 / メール / Slack のコピペ>
```

案件 slug(例: `clinic-reservation`)を1問だけ聞かれるので答えてください。

### 4. フェーズ1〜6(7)が順に進む

Claude が Phase 1(ヒアリング)から Phase 6(プロトタイプ実装)までを順に起動します。
各フェーズの終わりに成果物を報告し、「フェーズNへ」と言えば次に進みます。
LLM を使うプロトの場合は Phase 7(プロンプト改善)も実行されます。

- 原文は `projects/<slug>/brief-original.md` に保存
- 各フェーズ成果物は `projects/<slug>/phase-*.md` に追加
- TBD(原文から読み取れない論点)は埋めずに明示され、商談で確認する材料になる

### 5. プロトタイプ完成 → 商談へ

プロトタイプは `projects/<slug>/prototype/index.html` に生成されます。ブラウザで開くだけ。
要件定義書・利用シナリオなどの商談用補助資料も同じ `projects/<slug>/` 配下にまとまります。
修正したいときは **「タイトルを○○に変えて」「背景を青にして」** と話しかければOK。

### 6. 商談後 → フェーズ8〜9

商談後に「検証結果はこうだった」と伝えると Phase 8(ユーザー検証)→ Phase 9(改善方針)が起動します。
学びは `learnings/` に記録され、再現パターンは `recipes/` に昇格して次の案件に活かされます。
日を跨いでも `STATUS.md` で進捗が管理されているので、「続きから」と言えば再開できます。

## ディレクトリ構成

```
.
├── CLAUDE.md            # Claude Code 向け司令塔ルール
├── AGENTS.md            # Codex 向け同等ルール
├── SECURITY.md          # 脅威モデルと防御層
├── USAGE.md             # 非エンジニア向け詳細ガイド
├── .claude/
│   ├── agents/          # requirements-interviewer / template-selector
│   ├── skills/          # prototype-flow / phase-1〜9 / design-system / history-reuse
│   └── settings.json    # 権限・フック設定
├── templates/           # 6種の固定テンプレ(静的HTML)
├── scripts/
│   ├── verify.sh        # 生成物検証
│   └── append-history.sh
├── projects/            # 案件ごとの成果物(phase-1〜9)(gitignore)
├── learnings/           # 単発の学び記録
├── recipes/             # 2回以上再現した成功パターン
├── output/              # 旧構造(後方互換・gitignore)
├── specs/               # 旧構造(後方互換・gitignore)
└── history/             # 旧構造・生成履歴ログ
```

## 設計原則(抜粋)

- **技術選択をユーザーに聞かない** — React/Vue 等の語彙は裏に隠す
- **テンプレ外の機能を勝手に追加しない** — スコープ肥大化防止
- **エラーをユーザーに見せない** — 自己修復後に結果だけ伝える
- **書き込み先は `projects/` `learnings/` `recipes/` に限定** — 旧 `output/` `specs/` `history/` は読み取り専用
- **生成物は選定されたプロトタイプ種別に準拠** — 種別外の機能を勝手に追加しない
- **外部APIはキー不要な公開APIのみ fetch 可**、キー付きは mock で代替(漏洩防止)

詳細は [`CLAUDE.md`](./CLAUDE.md) / [`SECURITY.md`](./SECURITY.md) を参照。

## よくある質問

**Q. 完成後に編集したい**
「○○の色を青にして」と話しかければ Claude が直接修正します。

**Q. エラーが出たら?**
自動で最大3回まで自己修復します。ユーザーは何もしなくて大丈夫です。

**Q. 前に作ったやつを流用したい**
「前回のカフェをベースにパン屋さんにして」のように頼むと、`projects/` と `recipes/` を検索して再利用します。

**Q. 外部APIのキーは安全?**
現段階ではフロントに露出させない方針で、キー必須APIは mock データで描画します。キー付きAPIを本物で叩きたい場合はローカル proxy サイドカー方式を別途設計予定。

**Q. Codex でも使える?**
使えます。`AGENTS.md` がエントリポイントで、Claude Code の `CLAUDE.md` とほぼ同内容です。

## ライセンス

(未設定)
