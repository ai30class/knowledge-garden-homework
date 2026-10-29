#!/bin/bash
# 上線健康檢查：首頁要 200、亂打的網址要 404（不能 500）、頁面不能載入第三方程式。
# 部署完執行：bash check.sh（預設新網址）；也可以 bash check.sh https://ai30class.github.io/knowledge-garden-homework
BASE="${1:-https://garden.ai30class.com}"
fail=0
check() { # 說明 網址路徑 期待的狀態碼
  local got
  got=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$BASE$2")
  if [ "$got" = "$3" ]; then echo "✓ $1（$2 → $got）"
  else echo "✗ $1（$2 → $got，應該是 $3）"; fail=1; fi
}
check "首頁打得開" "/" 200
check "manifest 在" "/manifest.json" 200
check "離線快取程式在" "/sw.js" 200
check "亂打的網址回「不存在」、不當掉" "/check-not-exist-$(date +%s)" 404
check "亂打的網址（.npmrc）回「不存在」" "/.npmrc" 404
# 2026-10-30：沒加 s 的 http 網址要轉到 https（不然 Safari 標「不安全」）
case "$BASE" in https://*)
  loc=$(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' --max-time 20 "http://${BASE#https://}/")
  if [ "$loc" = "301 $BASE/" ]; then echo "✓ http 會轉成 https（$loc）"; else echo "✗ http 沒有轉成 https（$loc）"; fail=1; fi ;;
esac
# 同源規矩：不准有第三方程式（只允許 Google Fonts 字型）
ext=$(curl -s --max-time 20 "$BASE/" | grep -oE '<script[^>]+src="https?://[^"]+"' | grep -v 'fonts.googleapis.com' )
if [ -z "$ext" ]; then echo "✓ 沒有載入第三方程式"; else echo "✗ 有第三方程式：$ext"; fail=1; fi
if [ "$fail" = 0 ]; then echo "全部正常：$BASE"
else echo "⚠️ 有項目不對，網站可能出問題了：$BASE"; exit 1; fi
