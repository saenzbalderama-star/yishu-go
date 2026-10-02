#!/usr/bin/env bash
# 把当前的 cpolar 公网地址写进 address.txt 并推送到 GitHub。
#
# 朋友访问的是 Pages 上的固定地址（跳转页），跳转页读这个文件自动跟到最新地址。
# 所以隧道地址再怎么变，发给朋友的链接一辈子不用改。
#
# 用法：
#   ./share-redirect/update-current-url.sh              # 自动探测
#   ./share-redirect/update-current-url.sh https://xxx  # 手动指定
set -u
cd "$(dirname "$0")"

URL="${1:-}"

# 1) 优先用 cpolar 管理接口
if [ -z "$URL" ]; then
  URL=$(curl -s --noproxy '*' -m 8 http://127.0.0.1:4042/api/tunnels 2>/dev/null \
    | /usr/bin/python3 -c "
import sys, json
try:
    ts = json.load(sys.stdin).get('tunnels', [])
    print(next((t['public_url'] for t in ts if str(t.get('public_url','')).startswith('https')), ''))
except Exception:
    print('')
" 2>/dev/null || echo '')
fi

# 2) 接口不通就从 cpolar 日志里解析（推荐把隧道输出重定向到 /tmp/cpolar.log）
if [ -z "$URL" ] && [ -f /tmp/cpolar.log ]; then
  URL=$(grep -oE 'https://[a-z0-9]+\.r[0-9]*\.cpolar\.(top|cn|io)' /tmp/cpolar.log 2>/dev/null | tail -1 || echo '')
fi

if [ -z "$URL" ]; then
  echo "❌ 没拿到地址。先起隧道："
  echo "     cpolar http 8002 > /tmp/cpolar.log 2>&1 &"
  echo "   或者手动指定："
  echo "     $0 https://你的地址.r3.cpolar.top"
  exit 1
fi

# 3) 地址没变就不折腾 git
if [ -f address.txt ] && [ "$(cat address.txt)" = "$URL" ]; then
  echo "✓ 地址未变：$URL"
  exit 0
fi

echo "$URL" > address.txt
echo "✓ 已写入：$URL"

# 4) 推到 GitHub，Pages 上的跳转页随即生效
git add address.txt
git commit -m "更新分享地址 $URL" -q
git push -q && echo "✓ 已推送，朋友那边几秒后自动跟到新地址"
