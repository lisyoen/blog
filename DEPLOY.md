# Blog 배포 가이드

## Ubuntu miniPC Apache 서버 배포

### 사전 준비사항

1. **miniPC 정보 확인**
   - IP 주소 또는 호스트명
   - SSH 사용자명
   - SSH 접근 권한

2. **배포 스크립트 설정**
   
   `deploy-to-apache.ps1` (Windows) 또는 `deploy-to-apache.sh` (Linux/Mac) 파일을 열고 다음 변수를 수정:
   ```powershell
   $MINIPC_HOST = "192.168.1.100"  # miniPC IP 주소
   $MINIPC_USER = "yourusername"    # SSH 사용자명
   ```

### 배포 방법

#### Windows에서 배포:
```powershell
cd D:\git\blog
.\deploy-to-apache.ps1
```

#### Linux/Mac에서 배포:
```bash
cd /path/to/blog
chmod +x deploy-to-apache.sh
./deploy-to-apache.sh
```

### 수동 배포 (단계별)

1. **SSH로 miniPC 접속**
   ```bash
   ssh username@minipc
   ```

2. **아파치 디렉토리 생성**
   ```bash
   sudo mkdir -p /var/www/html/blog
   ```

3. **Windows에서 파일 전송 (SCP)**
   ```powershell
   scp -r D:\git\blog\* username@minipc:/tmp/blog_upload/
   ```

4. **miniPC에서 파일 이동**
   ```bash
   sudo mv /tmp/blog_upload/* /var/www/html/blog/
   sudo chown -R www-data:www-data /var/www/html/blog
   sudo chmod -R 755 /var/www/html/blog
   ```

5. **아파치 설정 (필요시)**
   
   `/etc/apache2/sites-available/000-default.conf` 또는 새 사이트 설정 파일:
   ```apache
   <VirtualHost *:80>
       ServerName minipc.local
       DocumentRoot /var/www/html
       
       <Directory /var/www/html/blog>
           Options Indexes FollowSymLinks
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```

6. **아파치 재시작**
   ```bash
   sudo systemctl restart apache2
   ```

### 접속

배포 후 브라우저에서 접속:
- `http://minipc/blog`
- `http://192.168.1.100/blog` (실제 IP로 변경)

### 문제 해결

#### 403 Forbidden 에러
```bash
sudo chmod -R 755 /var/www/html/blog
sudo chown -R www-data:www-data /var/www/html/blog
```

#### 아파치 상태 확인
```bash
sudo systemctl status apache2
sudo apache2ctl -t  # 설정 파일 문법 검사
```

#### 로그 확인
```bash
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/apache2/access.log
```
