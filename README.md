# Jasper Studio + Git + Jasper Server Version Control

## Tổng quan

Repository này sử dụng REST API để đồng bộ giữa:
- **Jasper Studio**: Thiết kế và chỉnh sửa reports
- **Git**: Quản lý version control  
- **Jasper Server**: Deploy và chạy reports

## Cấu trúc thư mục

```
Version_control_demo/
├── reports/           # Reports (.jrxml files)
├── adhoc/            # Ad-hoc views và topics
├── images/           # Resources (images, fonts, etc.)
├── temp/             # Temporary files
├── push-to-server.sh # Script push lên server
└── pull-from-server.sh # Script pull từ server
```

## Cấu hình

Chỉnh sửa trong các script:

```bash
JASPER_URL="http://localhost:8080/jasperserver-pro"
USERNAME="jasperadmin"
PASSWORD="jasperadmin"
```

## Quy trình làm việc

### 1. Khi chỉnh sửa trong Jasper Studio

```bash
# Chỉnh sửa files trong Studio
# Commit changes vào Git
git add .
git commit -m "Updated report XYZ"
git push

# Deploy lên server (chỉ push files thay đổi)
./push-to-server.sh
```

### 2. Khi pull updates từ Git và deploy

```bash
# Pull latest changes
git pull origin main

# Push lên server
./push-to-server.sh
```

### 3. Khi có thay đổi trên server

```bash
# Pull từ server về local
./pull-from-server.sh

# Refresh project trong Studio (F5)
```

## Tính năng

- ✅ **Smart push**: Chỉ upload files thay đổi (git diff)
- ✅ **REST API**: Sử dụng Jasper REST API, không phụ thuộc ant
- ✅ **Auto mapping**: Tự động map local paths sang server resources
- ✅ **Error handling**: Chi tiết logging và error messages
- ✅ **Session management**: Tự động login/logout

## File mapping

- `reports/` → `/reports/` trên server
- `adhoc/` → `/adhoc/` trên server  
- `images/` → `/images/` trên server

## Troubleshooting

### Lỗi login
```bash
# Kiểm tra server running
curl http://localhost:8080/jasperserver-pro

# Kiểm tra credentials trong script
```

### Lỗi upload
```bash
# Check logs trong temp/
ls -la temp/
```

## Scripts

- `push-to-server.sh`: Upload changed files to server
- `pull-from-server.sh`: Download changes from server
