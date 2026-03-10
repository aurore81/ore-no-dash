#!/bin/zsh
# ore-no-dash Cloudflare Pages 배포
# 사용법: ./deploy.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

ACCOUNT_ID="2e5c5e7f6c488572fe1c2e899e3e4fa2"
PROJECT_NAME="ore-no-dash"
NTFY_TOPIC="aurore-deploy-af55e122"
SITE_URL="https://home.aurore.work"
ZONE_ID="e982b59c13b6750675ff70dacf2bd0c9"

echo "📊 배포 통계 수집 중..."
DEPLOY_DATA=$(curl -s "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/pages/projects/$PROJECT_NAME/deployments?per_page=1" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" 2>/dev/null)

TOTAL=$(echo "$DEPLOY_DATA" | jq -r '.result_info.total_count // 0')
LAST_AT=$(echo "$DEPLOY_DATA" | jq -r '.result[0].created_on // empty')
LAST_STATUS=$(echo "$DEPLOY_DATA" | jq -r '.result[0].latest_stage.status // "unknown"')

# +1 for this deployment
TOTAL=$((TOTAL + 1))

cat > public/deploy-stats.json <<STATS
{"total":$TOTAL,"lastDeployedAt":"$(date -u '+%Y-%m-%dT%H:%M:%SZ')","lastStatus":"success","project":"$PROJECT_NAME"}
STATS
echo "  배포 #$TOTAL"

# 최근 커밋 메시지
COMMIT_MSG=$(git log -1 --pretty=%s 2>/dev/null || echo "수동 배포")

echo "🔨 빌드 중..."
npm run build

echo "🚀 Cloudflare Pages 배포 중..."
if npx wrangler pages deploy dist --project-name "$PROJECT_NAME" --commit-dirty=true --commit-message "Deploy #$TOTAL $(date '+%Y-%m-%d %H:%M')"; then
  echo "✅ 배포 완료! (#$TOTAL) $SITE_URL"

  # Cloudflare 캐시 퍼지
  echo "🧹 캐시 퍼지 중..."
  curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"hosts":["home.aurore.work"]}' >/dev/null 2>&1 && echo "  캐시 퍼지 완료" || echo "  캐시 퍼지 실패 (무시)"

  # 성공 알림
  curl -s \
    -H "Title: 🚀 수동 배포 완료! #$TOTAL" \
    -H "Priority: default" \
    -H "Tags: rocket,white_check_mark" \
    -H "Click: $SITE_URL" \
    -H "Actions: view, 사이트 열기, $SITE_URL" \
    -d "✅ ore-no-dash 수동 배포 성공!

📝 $COMMIT_MSG
🔢 배포 #$TOTAL
⏰ $(date '+%m/%d %H:%M')
🌐 $SITE_URL" \
    "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &
else
  echo "❌ 배포 실패!"

  # 실패 알림
  curl -s \
    -H "Title: ❌ 수동 배포 실패! ore-no-dash" \
    -H "Priority: high" \
    -H "Tags: x,warning" \
    -d "❌ ore-no-dash 수동 배포 실패!

📝 $COMMIT_MSG
⏰ $(date '+%m/%d %H:%M')" \
    "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 &

  exit 1
fi
