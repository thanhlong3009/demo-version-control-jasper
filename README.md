# Jasper Studio + Git + Jasper Server Version Control Demo

## Tổng quan
Repository này demo quy trình version control cho Jasper reports sử dụng:
- **Jasper Studio**: Để thiết kế và chỉnh sửa reports
- **Git**: Để quản lý version control
- **Jasper Server**: Để deploy và chạy reports

## Cấu trúc thư mục
```
Version_control_demo/
├── reports/           # Reports (.jrxml files)
├── adhoc/            # Ad-hoc views và topics
├── images/           # Resources (images, fonts, etc.)
├── temp/             # Temporary files
├── js-export.properties   # Cấu hình export từ server
├── js-import.properties   # Cấu hình import lên server
├── pull-from-server.sh    # Script pull từ server
└── push-to-server.sh      # Script push lên server
```

## Thiết lập ban đầu

### 1. Cấu hình Jasper Server connection
Chỉnh sửa file `js-export.properties` và `js-import.properties`:
```properties
js-uri=http://localhost:8080/jasperserver-pro/
js-username=jasperadmin
js-password=jasperadmin
organization=organization_1
```

### 2. Cấu hình đường dẫn JS utilities
Chỉnh sửa trong các file `.sh`:
```bash
JS_EXPORT_PATH="/path/to/buildomatic/js-export.sh"
JS_IMPORT_PATH="/path/to/buildomatic/js-import.sh"
```

### 3. Phân quyền execute cho scripts
```bash
chmod +x pull-from-server.sh
chmod +x push-to-server.sh
```

## Quy trình làm việc

### Khi chỉnh sửa trong Jasper Studio:

1. **Mở project trong Jasper Studio**
   - File > Switch Workspace > Chọn thư mục cha của Version_control_demo
   - Import project hoặc tạo new project trỏ đến thư mục này

2. **Chỉnh sửa reports**
   - Tạo/sửa .jrxml files trong thư mục `reports/`
   - Test reports trong Jasper Studio

3. **Commit thay đổi vào Git**
   ```bash
   git add .
   git commit -m "Updated report XYZ"
   git push origin main
   ```

4. **Deploy lên Jasper Server**
   ```bash
   ./push-to-server.sh
   ```

### Khi có thay đổi trên Jasper Server:

1. **Pull thay đổi từ server về local**
   ```bash
   ./pull-from-server.sh
   ```

2. **Refresh project trong Jasper Studio**
   - Right-click project > Refresh
   - Hoặc F5

## Các lệnh Git thường dùng

```bash
# Xem status
git status

# Xem diff
git diff

# Xem history
git log --oneline

# Tạo branch mới
git checkout -b feature/new-report

# Merge branch
git checkout main
git merge feature/new-report

# Pull từ remote
git pull origin main
```

## Troubleshooting

### Lỗi connection đến Jasper Server
- Kiểm tra server có đang chạy: http://localhost:8080/jasperserver-pro/
- Kiểm tra username/password trong .properties files
- Kiểm tra firewall/proxy settings

### Lỗi js-export/js-import not found
- Cập nhật đường dẫn trong scripts
- Thường ở: `[JASPERSOFT_HOME]/buildomatic/`

### Conflicts khi merge
```bash
git status
# Sửa conflicts manually
git add .
git commit -m "Resolved conflicts"
```
