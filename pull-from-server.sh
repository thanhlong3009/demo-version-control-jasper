#!/bin/bash

# Script để export từ Jasper Server về local repository
echo "🔄 Đang export từ Jasper Server về local..."

# Đường dẫn đến js-export utility (thay đổi theo môi trường của bạn)
JS_EXPORT_PATH="/Applications/jasperreports-server-9.0.0/buildomatic/js-export.sh"

# Kiểm tra xem js-export có tồn tại không
if [ ! -f "$JS_EXPORT_PATH" ]; then
    echo "❌ Không tìm thấy js-export.sh tại: $JS_EXPORT_PATH"
    echo "Vui lòng cập nhật JS_EXPORT_PATH trong script này"
    exit 1
fi

# Chạy export
$JS_EXPORT_PATH --propsFile js-export.properties

if [ $? -eq 0 ]; then
    echo "✅ Export thành công từ Jasper Server"
    
    # Kiểm tra có thay đổi nào không
    if [ -n "$(git status --porcelain)" ]; then
        echo "📝 Có thay đổi mới từ Jasper Server:"
        git status --short
        
        echo "Bạn có muốn commit những thay đổi này? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "Auto sync from Jasper Server - $(date '+%Y-%m-%d %H:%M:%S')"
            echo "✅ Đã commit thay đổi từ Jasper Server"
        fi
    else
        echo "ℹ️ Không có thay đổi nào từ Jasper Server"
    fi
else
    echo "❌ Export thất bại"
    exit 1
fi