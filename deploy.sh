#!/bin/zsh
# ore-no-dash Cloudflare Pages 배포
# 사용법: ./deploy.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "🔨 빌드 중..."
npm run build

echo "🚀 Cloudflare Pages 배포 중..."
npx wrangler pages deploy dist --project-name ore-no-dash --commit-dirty=true --commit-message "Deploy $(date '+%Y-%m-%d %H:%M')"

echo "✅ 배포 완료!"
