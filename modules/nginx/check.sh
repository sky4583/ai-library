#!/bin/bash

# =================================================================
# Nginx Check Module
# Path: modules/nginx/check.sh
# =================================================================

echo ">>> 正在驗證 Nginx 狀態..."

# 1. 檢查二進位檔案與版本
if nginx -v >/dev/null 2>&1; then
    echo "[OK] Nginx binary found: $(nginx -v 2>&1)"
else
    echo "[FAIL] Nginx command not found."
    echo "STATUS: FAILED"
    exit 1
fi

# 2. 檢查服務是否運行中
if systemctl is-active --quiet nginx; then
    echo "[OK] Nginx service is running."
else
    echo "[FAIL] Nginx service is not active."
    echo "STATUS: FAILED"
    exit 1
fi

# 3. 檢查 80 埠口是否監聽
if ss -tuln | grep -q ":80 "; then
    echo "[OK] Port 80 is listening."
    echo "STATUS: SUCCESS"
    exit 0
else
    echo "[FAIL] Port 80 is not responding."
    echo "STATUS: FAILED"
    exit 1
fi
