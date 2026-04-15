---
name: template-selector
description: 構造化仕様書（specs/*.yaml）を読み、templates/ から最適なテンプレートを1つ選定する。技術選択をユーザーから完全に隠蔽する。
---

# Template Selector

## 役割
`specs/*.yaml` の `purpose` フィールドを見て、`templates/` から1つテンプレを選びます。
**ユーザーには技術名を一切見せません。**

## 選定ロジック

| purpose | 選ぶテンプレ |
|---|---|
| `landing` | `templates/landing-page/` |
| `form` | `templates/form-app/` |
| `chatbot` | `templates/chatbot/` |
| `dashboard` | `templates/dashboard/` |
| `booking` | `templates/booking/` |
| `portfolio` | `templates/portfolio/` |

## スタイル適用

`style` フィールドに応じて、テンプレ内の CSS 変数を上書き：

| style | primary | bg | text |
|---|---|---|---|
| `minimal` | `#000000` | `#ffffff` | `#111111` |
| `colorful` | `#ff6b6b` | `#fff9e6` | `#2d3436` |
| `business` | `#1e3a5f` | `#f5f7fa` | `#1a1a1a` |

## 参考デザイン原則

**必ず** `.claude/skills/design-system/SKILL.md` を参照してから適用する。
カラー・タイポ・余白・アクセシビリティの基準が定義されている。

## 手順

1. `specs/` から最新の spec.yaml を読む
2. 上記ロジックでテンプレを選ぶ
3. `output/<project_name>/` にテンプレをコピー（`cp -r`）
4. `output/<project_name>/index.html` の以下を置換：
   - `{{TITLE}}` → `spec.title`
   - `{{DESCRIPTION}}` → `spec.description`
   - `{{PRIMARY_COLOR}}` → スタイル表の primary
   - `{{BG_COLOR}}` → スタイル表の bg
   - `{{TEXT_COLOR}}` → スタイル表の text
   - `{{ITEMS}}` → required_items を HTML リストに変換
5. 完了したら `prototype-flow` スキルの STEP 4（検証）に進む

## ユーザーへの報告

技術名は言わない。例：
- ❌「Next.js テンプレで生成中…」
- ✅「デザインを調整しています…」
