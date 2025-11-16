# Blog Apache 배포 스크립트
# Ubuntu miniPC에 blog를 배포합니다

# 설정 변수
$MINIPC_HOST = "minipc"
$MINIPC_USER = "lisyoen"
$BLOG_PATH = "D:\git\blog"
$APACHE_ROOT = "/var/www/html/blog"  # 아파치 웹 루트 경로

Write-Host "=== Blog 배포 스크립트 ===" -ForegroundColor Cyan
Write-Host "대상: $MINIPC_USER@$MINIPC_HOST" -ForegroundColor Yellow
Write-Host "경로: $APACHE_ROOT" -ForegroundColor Yellow
Write-Host ""

# 1. 임시 압축 파일 생성
Write-Host "[1/4] 파일 압축 중..." -ForegroundColor Green
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipFile = "$env:TEMP\blog_$timestamp.zip"
Compress-Archive -Path "$BLOG_PATH\*" -DestinationPath $zipFile -Force

# 2. SCP로 파일 전송
Write-Host "[2/4] miniPC로 파일 전송 중..." -ForegroundColor Green
scp $zipFile "${MINIPC_USER}@${MINIPC_HOST}:/tmp/blog.zip"

if ($LASTEXITCODE -ne 0) {
    Write-Host "파일 전송 실패!" -ForegroundColor Red
    Remove-Item $zipFile
    exit 1
}

# 3. SSH로 접속하여 아파치 디렉토리에 압축 해제
Write-Host "[3/4] 서버에서 파일 배포 중..." -ForegroundColor Green
$sshCommands = @"
sudo mkdir -p $APACHE_ROOT
sudo rm -rf $APACHE_ROOT/*
sudo unzip -o /tmp/blog.zip -d $APACHE_ROOT
sudo chown -R www-data:www-data $APACHE_ROOT
sudo chmod -R 755 $APACHE_ROOT
rm /tmp/blog.zip
echo '배포 완료!'
"@

ssh "${MINIPC_USER}@${MINIPC_HOST}" $sshCommands

if ($LASTEXITCODE -ne 0) {
    Write-Host "서버 배포 실패!" -ForegroundColor Red
    Remove-Item $zipFile
    exit 1
}

# 4. 정리
Write-Host "[4/4] 정리 중..." -ForegroundColor Green
Remove-Item $zipFile

Write-Host ""
Write-Host "✓ 배포 완료!" -ForegroundColor Green
Write-Host "브라우저에서 http://${MINIPC_HOST}/blog 를 열어보세요" -ForegroundColor Cyan
