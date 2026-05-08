#!/bin/bash

# =================================================================
# Nginx Check Module
# Path: modules/nginx/check.sh
# =================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo ">>> 正在驗證 Nginx 狀態..."

# 1. 檢查二進位檔案與版本
if nginx -v >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} Nginx binary found: $(nginx -v 2>&1)"
else
    echo -e "${RED}[FAIL]${NC} Nginx command not found."
    exit 1
fi

# 2. 檢查服務是否運行中
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}[OK]${NC} Nginx service is running."
else
    echo -e "${RED}[FAIL]${NC} Nginx service is not active."
    exit 1
fi

# 3. 檢查 80 埠口是否監聽
if ss -tuln | grep -q ":80 "; then
    echo -e "${GREEN}[OK]${NC} Port 80 is listening."
    echo -e "${GREEN}STATUS: SUCCESS${NC}"
    exit 0
else
    echo -e "${RED}[FAIL]${NC} Port 80 is not responding."
    exit 1
fi
