---
name: prototype-flow
description: 非エンジニアの一言リクエストから動くプロトタイプを生成するメインワークフロー。「プロトタイプ作って」「〜のアプリ作って」「〜のサイト作って」などの依頼時に必ず起動する。
---

# Prototype Flow

## 起動条件
ユーザーから以下のような依頼があったとき：
- 「〜を作って」「〜のサイト作って」「〜のアプリ欲しい」
- 「プロトタイプ作りたい」「試作したい」

## 実行手順

### STEP 1: ヒアリング 🎤
- `requirements-interviewer` エージェントを起動
- 最大5問でヒアリング
- `specs/<timestamp>-spec.yaml` を出力
- ユーザーに「ヒアリング完了」と一言報告

### STEP 2: テンプレ選定 🎨
- `template-selector` エージェントを起動
- `templates/` から1つコピーし `output/<project_name>/` に配置
- プレースホルダを spec の値で置換
- ユーザーに「デザイン調整中…」と一言報告

### STEP 3: 生成 🏗️
- HTML が完成したか確認
- `{{...}}` プレースホルダが残っていないか確認
- 残っていたら Edit で削除または置換
- `spec.external_api` がある場合は **fetch + mock フォールバック**を埋め込む（下記パターン固定）

#### 外部API埋め込みパターン（固定）

```html
<script>
  const MOCK = /* spec.external_api[].mock をそのまま埋め込む */;
  const USE_REAL = /* auth==="none" なら true, それ以外は false */;
  const ENDPOINT = /* spec.external_api[].endpoint */;

  async function loadData() {
    if (!USE_REAL) return MOCK;
    try {
      const r = await fetch(ENDPOINT);
      if (!r.ok) throw new Error();
      return await r.json();
    } catch {
      return MOCK; // CORS/4xx/5xx は黙ってmockへ
    }
  }
  loadData().then(render);
</script>
```

**絶対ルール**:
- APIキーを HTML に書かない（`auth: key` は mock のみ使用）
- ユーザーにエラーを見せない。失敗は全部 mock に吸収させる

### STEP 4: 検証 ✅
以下を順番にチェック：
1. `output/<project_name>/index.html` が存在するか
2. `<html>` `</html>` タグが閉じているか
3. `{{` が残っていないか
4. 外部 CDN（Tailwind）へのリンクが生きているか

エラーがあれば**最大3回**まで自己修復ループ。
3回超えたらユーザーに「手動確認が必要な箇所があります」と報告。

### STEP 5: プレビュー & 履歴記録 🚀

**(A) 履歴追記（省略禁止）**

`history/index.jsonl` に以下の1行を追記する：

```json
{"id":"<timestamp>","project_name":"<name>","template":"<template>","title":"<title>","purpose":"<purpose>","style":"<style>","spec_path":"specs/<...>.yaml","output_path":"output/<name>","created_at":"<iso8601>","summary":"<一行要約>"}
```

履歴ファイルが存在しない場合は新規作成する。既存行は**絶対に上書きしない**（追記のみ）。

**(B) ユーザーへの完成報告**

```
✨ プロトタイプ完成！

📂 場所: output/<project_name>/index.html
👀 プレビュー: 下記コマンドで開きます

  open output/<project_name>/index.html

何か修正したい点があれば教えてください。
（例：「タイトルを○○に変えて」「背景を青にして」）
```

## 禁止事項

1. **5問を超えるヒアリング**（冗長化の元）
2. **テンプレに無い機能の勝手な追加**（スコープ肥大化）
3. **技術名の言及**（React/Tailwind などの単語）
4. **エラー詳細の提示**（ユーザーは結果だけ知りたい）

## 反復修正フロー

プロトタイプ完成後にユーザーが修正を依頼した場合：
- 該当ファイルを Edit で直接修正
- 再度 STEP 4 の検証のみ実行
- 新しい spec.yaml は作らない（同じプロジェクト内で反復）
