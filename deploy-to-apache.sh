#!/bin/bash
# Blog Apache 배포 스크립트 (Linux/Mac용)

# 설정 변수 (실제 값으로 수정하세요)
MINIPC_HOST="minipc"  # miniPC의 IP 주소 또는 호스트명
MINIPC_USER="username"  # SSH 사용자명
BLOG_PATH="."
APACHE_ROOT="/var/www/html/blog"

echo "=== Blog 배포 스크립트 ==="
echo "대상: $MINIPC_USER@$MINIPC_HOST"
echo "경로: $APACHE_ROOT"
echo ""

# 1. 파일 동기화 (rsync 사용 - 더 효율적)
echo "[1/2] 파일 동기화 중..."
rsync -avz --delete \
    --exclude '.git' \
    --exclude 'deploy-*.ps1' \
    --exclude 'deploy-*.sh' \
    "$BLOG_PATH/" \
    "${MINIPC_USER}@${MINIPC_HOST}:/tmp/blog_upload/"

if [ $? -ne 0 ]; then
    echo "파일 전송 실패!"
    exit 1
fi

# 2. SSH로 접속하여 아파치 디렉토리로 이동
echo "[2/2] 서버에서 파일 배포 중..."
ssh "${MINIPC_USER}@${MINIPC_HOST}" << 'EOF'
sudo mkdir -p /var/www/html/blog
sudo rsync -a --delete /tmp/blog_upload/ /var/www/html/blog/
sudo chown -R www-data:www-data /var/www/html/blog
sudo chmod -R 755 /var/www/html/blog
rm -rf /tmp/blog_upload
echo "배포 완료!"
EOF

if [ $? -ne 0 ]; then
    echo "서버 배포 실패!"
    exit 1
fi

echo ""
echo "✓ 배포 완료!"
echo "브라우저에서 http://${MINIPC_HOST}/blog 를 열어보세요"
