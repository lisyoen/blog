# Blog 간단 배포 스크립트 (sudo 비밀번호 입력 방식)

$MINIPC_HOST = "minipc"
$MINIPC_USER = "lisyoen"
$BLOG_PATH = "D:\git\blog"

Write-Host "=== Blog 배포 스크립트 ===" -ForegroundColor Cyan
Write-Host "대상: $MINIPC_USER@$MINIPC_HOST" -ForegroundColor Yellow
Write-Host ""

# 1. rsync로 직접 동기화 (비밀번호는 한 번만 입력)
Write-Host "[1/2] 파일을 임시 위치에 업로드 중..." -ForegroundColor Green

# Windows에서 rsync가 없으면 scp 사용
scp -r "$BLOG_PATH\index.html" "${MINIPC_USER}@${MINIPC_HOST}:/tmp/"
if (Test-Path "$BLOG_PATH\posts") {
    scp -r "$BLOG_PATH\posts" "${MINIPC_USER}@${MINIPC_HOST}:/tmp/"
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "파일 전송 실패!" -ForegroundColor Red
    exit 1
}

# 2. SSH로 접속하여 sudo로 배포
Write-Host "[2/2] sudo로 배포 중 (비밀번호 입력 필요)..." -ForegroundColor Green
Write-Host "miniPC sudo 비밀번호를 입력하세요:" -ForegroundColor Yellow

ssh -t "${MINIPC_USER}@${MINIPC_HOST}" @"
sudo mkdir -p /var/www/html/blog
sudo cp -r /tmp/index.html /var/www/html/blog/
if [ -d /tmp/posts ]; then
    sudo cp -r /tmp/posts /var/www/html/blog/
fi
sudo chown -R www-data:www-data /var/www/html/blog
sudo chmod -R 755 /var/www/html/blog
rm -f /tmp/index.html
rm -rf /tmp/posts
echo ''
echo '✓ 배포 완료!'
"@

if ($LASTEXITCODE -ne 0) {
    Write-Host "배포 실패!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✓ 배포 완료!" -ForegroundColor Green
Write-Host "브라우저에서 http://minipc/blog 를 열어보세요" -ForegroundColor Cyan
