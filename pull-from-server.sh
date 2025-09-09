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

# Jasper Server REST API Configuration
JASPER_URL="http://localhost:8080/jasperserver-pro"
USERNAME="jasperadmin"
PASSWORD="jasperadmin"
ORGANIZATION=""

# Current directory
CURRENT_DIR="$(pwd)"
TEMP_DIR="$CURRENT_DIR/temp"
COOKIE_FILE="$TEMP_DIR/jasper_session.txt"
EXPORT_DIR="$CURRENT_DIR"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Login to Jasper Server
login_jasper() {
    log "🔐 Logging into Jasper Server..."
    
    local login_response=$(curl -s -c "$COOKIE_FILE" \
        -d "j_username=$USERNAME" \
        -d "j_password=$PASSWORD" \
        -d "orgId=$ORGANIZATION" \
        -X POST "$JASPER_URL/j_spring_security_check" \
        -w "%{http_code}")
    
    if [[ "$login_response" == *"200"* ]] || [[ "$login_response" == *"302"* ]]; then
        success "✅ Login successful"
        return 0
    else
        error "❌ Login failed (HTTP: $login_response)"
        return 1
    fi
}

# Export resources from Jasper Server
export_resources() {
    local resource_path="$1"
    local local_path="$2"
    
    log "📥 Exporting: $resource_path"
    
    # Create directory if not exists
    mkdir -p "$(dirname "$local_path")"
    
    # Download resource
    local response=$(curl -s -b "$COOKIE_FILE" \
        "$JASPER_URL/rest_v2/resources$resource_path" \
        -H "Accept: application/json" \
        -w "%{http_code}" \
        -o "$local_path")
    
    local http_code="${response: -3}"
    
    if [[ "$http_code" == "200" ]]; then
        success "✅ Exported: $(basename "$local_path")"
        return 0
    else
        error "❌ Export failed: $resource_path (HTTP: $http_code)"
        return 1
    fi
}

# List all resources from server
list_resources() {
    log "📋 Listing resources from server..."
    
    # Get all resources
    local resources_json="$TEMP_DIR/resources.json"
    
    curl -s -b "$COOKIE_FILE" \
        "$JASPER_URL/rest_v2/resources?recursive=true&type=reportUnit&type=dataType&type=file&type=img" \
        -H "Accept: application/json" \
        -o "$resources_json"
    
    if [ -f "$resources_json" ]; then
        # Parse JSON and extract resource URIs
        python3 -c "
import json
import sys
try:
    with open('$resources_json', 'r') as f:
        data = json.load(f)
    
    if 'resourceLookup' in data:
        for resource in data['resourceLookup']:
            uri = resource.get('uri', '')
            if uri.startswith(('/reports', '/adhoc', '/images')):
                print(uri)
except:
    pass
        " 2>/dev/null || echo "/reports /adhoc /images" | tr ' ' '\n'
    fi
}

# Map server resource path to local file path
map_to_local_path() {
    local resource_path="$1"
    local local_path
    
    # Remove leading /
    resource_path=$(echo "$resource_path" | sed 's|^/||')
    
    # Map to local structure
    case "$resource_path" in
        reports/*)
            local_path="reports/${resource_path#reports/}"
            ;;
        adhoc/*)
            local_path="adhoc/${resource_path#adhoc/}"
            ;;
        images/*)
            local_path="images/${resource_path#images/}"
            ;;
        *)
            local_path="downloads/$resource_path"
            ;;
    esac
    
    echo "$local_path"
}

# Main execution
main() {
    log "🚀 Starting Jasper Server Export..."
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        error "❌ Not in a git repository"
        exit 1
    fi
    
    # Login
    if ! login_jasper; then
        exit 1
    fi
    
    # Get list of resources to export
    local resources=$(list_resources)
    if [ -z "$resources" ]; then
        warning "⚠️ No resources found on server"
        exit 0
    fi
    
    log "📁 Resources to export:"
    echo "$resources" | while read -r resource; do
        echo "  - $resource"
    done
    
    # Export each resource
    local export_count=0
    local success_count=0
    
    echo "$resources" | while read -r resource; do
        if [ ! -z "$resource" ]; then
            export_count=$((export_count + 1))
            local_path=$(map_to_local_path "$resource")
            
            if export_resources "$resource" "$local_path"; then
                success_count=$((success_count + 1))
            fi
        fi
    done
    
    # Check for changes and commit if needed
    if [ -n "$(git status --porcelain)" ]; then
        log "📝 Changes detected from server:"
        git status --short
        
        echo "Do you want to commit these changes? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "Auto sync from Jasper Server - $(date '+%Y-%m-%d %H:%M:%S')"
            success "✅ Changes committed to git"
        fi
    else
        log "ℹ️ No changes detected"
    fi
    
    # Summary
    log "📊 Export Summary:"
    success "✅ Resources processed: $export_count"
    success "✅ Successful exports: $success_count"
    
    # Cleanup
    rm -f "$COOKIE_FILE" "$TEMP_DIR"/resources.json
}

# Run main function
main "$@"