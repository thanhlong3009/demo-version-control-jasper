#!/bin/bash

# Jasper Server REST API Configuration
JASPER_URL="http://localhost:8080/jasperserver-pro"
USERNAME="jasperadmin"
PASSWORD="jasperadmin"

# Current directory
CURRENT_DIR="$(pwd)"
TEMP_DIR="$CURRENT_DIR/temp"
COOKIE_FILE="$TEMP_DIR/jasper_session.txt"

# Create temp directory
mkdir -p "$TEMP_DIR"

echo "🚀 Starting Jasper Server Git Sync..."

# Login to Jasper Server
echo "🔐 Logging into Jasper Server..."
curl -s -c "$COOKIE_FILE" \
    -d "j_username=$USERNAME" \
    -d "j_password=$PASSWORD" \
    -X POST "$JASPER_URL/j_spring_security_check" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Login successful"
else
    echo "❌ Login failed"
    exit 1
fi

# Get changed files from git
echo "📋 Getting changed files from git..."
changed_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || git status --porcelain | awk '{print $2}' || find reports adhoc images -type f -name "*" | head -10)

if [ -z "$changed_files" ]; then
    echo "⚠️ No files to upload"
    exit 0
fi

echo "📁 Files to upload:"
echo "$changed_files"

# Upload each file
upload_count=0
success_count=0

for file in $changed_files; do
    if [ -f "$file" ]; then
        upload_count=$((upload_count + 1))
        echo "📤 Uploading: $file"
        
        # Create simple zip for this file
        zip_file="$TEMP_DIR/upload_$(basename "$file").zip"
        zip -j "$zip_file" "$file" > /dev/null 2>&1
        
        # Upload via REST API
        response=$(curl -s -b "$COOKIE_FILE" \
            -F "file=@$zip_file" \
            "$JASPER_URL/rest_v2/import" \
            -w "%{http_code}")
        
        http_code="${response: -3}"
        
        if [[ "$http_code" == "200" ]] || [[ "$http_code" == "201" ]]; then
            echo "✅ Uploaded: $(basename "$file")"
            success_count=$((success_count + 1))
        else
            echo "❌ Upload failed: $(basename "$file")"
        fi
        
        rm -f "$zip_file"
    fi
done

# Summary
echo "📊 Upload Summary:"
echo "✅ Files processed: $upload_count"
echo "✅ Successful uploads: $success_count"

if [ $success_count -gt 0 ]; then
    echo "🌐 Check your updates at: $JASPER_URL"
fi

# Cleanup
rm -f "$COOKIE_FILE"

echo "🎉 Done!"