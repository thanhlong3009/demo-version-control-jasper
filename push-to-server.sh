#!/bin/bash

# Script để import từ local repository lên Jasper Server
echo "🚀 Đang deploy lên Jasper Server..."

# Đường dẫn đến js-import utility (thay đổi theo môi trường của bạn)
JS_IMPORT_PATH="/Applications/jasperreports-server-9.0.0/buildomatic/js-import.sh"

# Kiểm tra xem js-import có tồn tại không
if [ ! -f "$JS_IMPORT_PATH" ]; then
    echo "❌ Không tìm thấy js-import.sh tại: $JS_IMPORT_PATH"
    echo "Vui lòng cập nhật JS_IMPORT_PATH trong script này"
    exit 1
fi

# Kiểm tra có thay đổi chưa commit không
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️ Có thay đổi chưa được commit:"
    git status --short
    echo "Bạn có muốn commit trước khi deploy? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Nhập commit message:"
        read -r commit_msg
        git add .
        git commit -m "$commit_msg"
        echo "✅ Đã commit thay đổi"
    fi
fi

# Chạy import
echo "📤 Đang upload lên Jasper Server..."
$JS_IMPORT_PATH --propsFile js-import.properties

if [ $? -eq 0 ]; then
    echo "✅ Deploy thành công lên Jasper Server"
    echo "🌐 Kiểm tra tại: http://localhost:8080/jasperserver-pro/"
else
    echo "❌ Deploy thất bại"
    exit 1
fi