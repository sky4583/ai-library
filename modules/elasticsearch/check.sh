#!/bin/bash

# =================================================================
# Elasticsearch Check Module
# Path: modules/elasticsearch/check.sh
# =================================================================

echo ">>> 正在驗證 Elasticsearch 狀態..."

# 1. 檢查服務是否運行中
if systemctl is-active --quiet elasticsearch; then
    echo "[OK] Elasticsearch service is running."
else
    echo "[FAIL] Elasticsearch service is not active."
    echo "STATUS: FAILED"
    exit 1
fi

# 2. 檢查 9200 埠口是否監聽
# 注意：Elasticsearch 8 預設開啟 HTTPS，這裡僅檢查埠口監聽狀況
if ss -tuln | grep -q ":9200 "; then
    echo "[OK] Port 9200 is listening."
    echo "STATUS: SUCCESS"
    exit 0
else
    echo "[FAIL] Port 9200 is not responding. (May still be starting up)"
    echo "STATUS: FAILED"
    exit 1
fi
