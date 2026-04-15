---
name: design-system
description: プロトタイプ生成時に適用する共通デザイン原則。配色・タイポ・余白・アクセシビリティの最低ラインを固定化して品質を安定させる。template-selector がテンプレ適用時に必ず参照する。
---

# Design System（ECC design-system / frontend-design / accessibility を下敷きに）

このハーネスで生成する全プロトタイプに共通で適用するデザイン原則。
**テンプレに閉じ込めず、ここで一元管理**することで、非エンジニアが作っても最低限のクオリティを担保する。

## 1. カラートークン（style プリセット）

| style | primary | bg | text | 用途 |
|---|---|---|---|---|
| `minimal` | `#000000` | `#ffffff` | `#111111` | 白黒＋アクセント1色。おしゃれ系・最小主義 |
| `colorful` | `#ff6b6b` | `#fff9e6` | `#2d3436` | 明るい・親しみやすい・飲食/子ども向け |
| `business` | `#1e3a5f` | `#f5f7fa` | `#1a1a1a` | 信頼感・BtoB・士業・金融 |

### コントラスト比（アクセシビリティ）
各プリセットは **WCAG AA（4.5:1）以上のコントラスト比**を満たすように選定済み。
新しい style を追加する際もこの基準を守ること。

## 2. タイポグラフィ

### スケール（モジュラー型）
```
xs    : 12px
sm    : 14px
base  : 16px   ← 本文
lg    : 18px
xl    : 20px
2xl   : 24px   ← セクション見出し
3xl   : 30px   ← ページ見出し
5xl   : 48px   ← ヒーロー大見出し
6xl   : 60px   ← ランディングの主役コピー
```

Tailwind のクラスと一致しているので、テンプレでは `text-3xl` のように指定するだけでよい。

### フォントファミリー
- 日本語: `-apple-system, system-ui, sans-serif`（OS 標準）
- 英数字混在: 同上（余計な Web フォントを読まない = 高速＆安全）
- 全テンプレ共通で `body { font-family: ... }` に適用済み

## 3. スペーシング（8px グリッド）

余白はすべて **4px または 8px の倍数**に統一：
```
4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96 / 128 (px)
```

Tailwind の `p-2` (8px), `p-4` (16px), `p-6` (24px), `p-8` (32px) をそのまま使う。

## 4. レイアウト原則

### 最大幅
- 本文コンテナ: `max-w-3xl` (768px) — 読みやすさ優先
- カードグリッド: `max-w-5xl` (1024px)
- ダッシュボード: 全幅 + サイドバー

### グリッド
- モバイル: 1カラム（デフォルト）
- デスクトップ: `md:grid-cols-3` または `md:grid-cols-2`
- ブレークポイントは Tailwind デフォルト（`md:` = 768px以上）

### 縦リズム
セクション間は `py-12` (48px) or `py-16` (64px) で統一。
**ヒーローだけ `py-20` (80px) or `py-24` (96px)** で強調する。

## 5. コンポーネント原則

### ボタン
- Primary: `btn-primary` クラス（`background: var(--primary); color: white`）
- 角丸: `rounded-full`（フレンドリー）または `rounded-lg`（ビジネス）
- ホバー: `hover:opacity-90 transition`

### カード
- `background: white`
- `border-radius: 12px` or `16px`
- `box-shadow: 0 2px 8px rgba(0,0,0,.06)` — 控えめに
- ホバーで `transform: translateY(-4px)` は作品系のみ

### フォーム入力
- `border` + `rounded-lg` + `focus:border-color: var(--primary)`
- ラベルは必ず `<label>` でマークアップ（アクセシビリティ）

## 6. アクセシビリティ最低ライン

**全テンプレ必須**：
1. `<html lang="ja">` を指定
2. `<title>` に意味あるタイトル
3. コントラスト比 WCAG AA 以上（カラートークンで担保）
4. フォームは `<label>` 必須、`required` 属性を付ける
5. ボタンは `<button>` タグ（`<div onclick>` 禁止）
6. 画像に `alt` 属性（画像なしプロトなら省略可）
7. キーボード操作可能（Tab フォーカス可視化）

## 7. 禁止事項

- **任意の Web フォント読み込み**（セキュリティ＆速度）
- **任意の CDN からの JS/CSS**（Tailwind CDN のみ許可）
- **インライン `style="..."` の多用**（CSS 変数で統一管理）
- **絶対 px 固定の幅指定**（レスポンシブ崩れ）
- **派手なアニメーション**（transition は `.2s` まで）

## 8. テンプレ編集時のチェックリスト

新しいテンプレを追加するとき：
- [ ] `:root` に `--primary`, `--bg`, `--text` 変数を定義
- [ ] `{{TITLE}}` `{{DESCRIPTION}}` `{{ITEMS}}` プレースホルダ対応
- [ ] Tailwind CDN を使う（他の CSS フレームワークは使わない）
- [ ] モバイルで崩れないことを確認（`md:` プレフィックス適切に）
- [ ] `<html lang="ja">` を含む
- [ ] 上記の余白・タイポスケールに従う

## 参考：ECC から取り入れた要素

| ECC の要素 | 本ハーネスでの採用箇所 |
|---|---|
| `design-system` | トークン一元管理（§1-3） |
| `frontend-design` | レイアウト原則（§4）とコンポーネント原則（§5） |
| `accessibility` | アクセシビリティ最低ライン（§6） |
| `frontend-patterns` | 各テンプレの構造パターン |
