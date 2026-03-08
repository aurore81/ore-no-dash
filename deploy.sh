#!/bin/zsh
# ore-no-dash Cloudflare Pages 배포
# 사용법: ./deploy.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

ACCOUNT_ID="2e5c5e7f6c488572fe1c2e899e3e4fa2"
PROJECT_NAME="ore-no-dash"

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

echo "🔨 빌드 중..."
npm run build

echo "🚀 Cloudflare Pages 배포 중..."
npx wrangler pages deploy dist --project-name "$PROJECT_NAME" --commit-dirty=true --commit-message "Deploy #$TOTAL $(date '+%Y-%m-%d %H:%M')"

echo "✅ 배포 완료! (#$TOTAL) https://home.aurore.work"
