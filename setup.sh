#!/bin/bash

# Script để setup môi trường development cho Jasper version control
echo "🔧 Thiết lập môi trường Jasper version control..."

# Tạo thư mục nếu chưa có
mkdir -p reports/source
mkdir -p reports/interactive  
mkdir -p adhoc/topics
mkdir -p images
mkdir -p temp

# Phân quyền cho scripts
chmod +x pull-from-server.sh
chmod +x push-to-server.sh

# Khởi tạo git nếu chưa có
if [ ! -d ".git" ]; then
    echo "📝 Khởi tạo Git repository..."
    git init
    git add .
    git commit -m "Initial commit - Jasper version control setup"
fi

echo "✅ Setup hoàn tất!"
echo ""
echo "📋 Các bước tiếp theo:"
echo "1. Cập nhật đường dẫn JS utilities trong pull-from-server.sh và push-to-server.sh"
echo "2. Kiểm tra cấu hình server trong js-*.properties files"
echo "3. Chạy ./pull-from-server.sh để sync dữ liệu ban đầu từ server"