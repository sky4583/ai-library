#!/bin/bash

# =================================================================
# PostgreSQL Check Module
# Path: modules/postgresql/check.sh
# =================================================================

echo ">>> 正在驗證 PostgreSQL 狀態..."

# 1. 檢查 5432 埠口是否監聽
if ss -tuln | grep -q ":5432 "; then
    echo "[OK] Port 5432 is listening."
    echo "STATUS: SUCCESS"
    exit 0
else
    echo "[FAIL] Port 5432 is not responding."
    echo "STATUS: FAILED"
    exit 1
fi
