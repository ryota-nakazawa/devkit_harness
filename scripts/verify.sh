#!/usr/bin/env bash
# Prototype Harness - 検証スクリプト
# Claude Code の PostToolUse フックと同等の検証を Codex など他環境でも実行可能にする。
#
# 使い方:
#   ./scripts/verify.sh output/mycafe
#   ./scripts/verify.sh output/mycafe/index.html

set -u

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <output/project_dir_or_html>"
  exit 1
fi

# ディレクトリが渡されたら index.html を対象にする
if [ -d "$TARGET" ]; then
  FILE="$TARGET/index.html"
else
  FILE="$TARGET"
fi

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found"
  exit 1
fi

ERRORS=0
WARNINGS=0

check_fail() {
  echo "  ✗ $1"
  ERRORS=$((ERRORS + 1))
}

check_warn() {
  echo "  ⚠ $1"
  WARNINGS=$((WARNINGS + 1))
}

check_pass() {
  echo "  ✓ $1"
}

echo "🔍 Verifying: $FILE"
echo ""

# 1. HTML 構造チェック
echo "[1] HTML 構造"
grep -q '<html' "$FILE" && check_pass "<html> タグあり" || check_fail "<html> タグが欠落"
grep -q '</html>' "$FILE" && check_pass "</html> タグあり" || check_fail "</html> タグが欠落"
grep -q '<head' "$FILE" && check_pass "<head> タグあり" || check_warn "<head> タグなし"
grep -q '<body' "$FILE" && check_pass "<body> タグあり" || check_fail "<body> タグが欠落"

# 2. プレースホルダ残留チェック
echo ""
echo "[2] プレースホルダ残留"
if grep -q '{{' "$FILE"; then
  check_fail "未置換のプレースホルダあり:"
  grep -o '{{[^}]*}}' "$FILE" | sort -u | sed 's/^/      /'
else
  check_pass "プレースホルダ全て置換済み"
fi

# 3. タイトル/説明の空チェック
echo ""
echo "[3] コンテンツ"
if grep -Eq '<title>[[:space:]]*</title>' "$FILE"; then
  check_fail "タイトルが空"
else
  check_pass "タイトル設定済み"
fi

# 4. Tailwind CDN の存在
echo ""
echo "[4] 外部リソース"
if grep -q 'cdn.tailwindcss.com' "$FILE"; then
  check_pass "Tailwind CDN リンクあり"
else
  check_warn "Tailwind CDN リンクなし（スタイルが当たらない可能性）"
fi

# 5. 許可外の外部 CDN 検出（セキュリティ）
FORBIDDEN_CDN=$(grep -oE 'src="https?://[^"]+"|href="https?://[^"]+"' "$FILE" | grep -v 'cdn.tailwindcss.com' | grep -v 'mailto:' | grep -v '#' || true)
if [ -n "$FORBIDDEN_CDN" ]; then
  check_warn "Tailwind 以外の外部リソース検出（ポリシー違反の可能性）:"
  echo "$FORBIDDEN_CDN" | sed 's/^/      /'
else
  check_pass "許可外の外部CDN なし"
fi

# 6. 危険コード検出（eval, innerHTML 直書きなど）
echo ""
echo "[5] セキュリティ"
if grep -qE '\beval\s*\(' "$FILE"; then
  check_fail "eval() 検出（禁止）"
else
  check_pass "eval() なし"
fi

if grep -qE 'document\.write\s*\(' "$FILE"; then
  check_fail "document.write() 検出（禁止）"
else
  check_pass "document.write() なし"
fi

# 7. ファイルサイズ（最低限の中身があるか）
echo ""
echo "[6] サイズ"
SIZE=$(wc -c < "$FILE" | tr -d ' ')
if [ "$SIZE" -lt 500 ]; then
  check_fail "ファイルが小さすぎる（${SIZE}バイト）— 生成失敗の可能性"
else
  check_pass "ファイルサイズ: ${SIZE} バイト"
fi

# 結果
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ FAIL — errors: $ERRORS, warnings: $WARNINGS"
  exit 2
elif [ "$WARNINGS" -gt 0 ]; then
  echo "⚠️  PASS with warnings — warnings: $WARNINGS"
  exit 0
else
  echo "✅ PASS"
  exit 0
fi
