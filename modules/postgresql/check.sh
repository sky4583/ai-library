#!/bin/bash

# =================================================================
# PostgreSQL Check Module
# Path: modules/postgresql/check.sh
# =================================================================

echo ">>> 正在驗證 PostgreSQL 狀態..."

# 1. 檢查服務是否運行中
if systemctl is-active --quiet postgresql; then
    echo -e "${GREEN}[OK]${NC} PostgreSQL 服務正在執行中"
else
    echo -e "${RED}[FAIL]${NC} PostgreSQL 服務未啟動"
    exit 1
fi

# 2. 檢查 5432 埠口是否監聽
if ss -tuln | grep -q ":5432 "; then
    echo -e "${GREEN}[OK]${NC} Port 5432 is listening."
else
    echo -e "${RED}[FAIL]${NC} Port 5432 is not responding."
    exit 1
fi

# 3. 深度檢查: 測試資料庫是否準備好接受連線
if command -v pg_isready >/dev/null 2>&1; then
    if pg_isready -q; then
        echo -e "${GREEN}[OK]${NC} PostgreSQL is ready to accept connections."
        echo "STATUS: SUCCESS"
        exit 0
    else
        echo -e "${RED}[FAIL]${NC} PostgreSQL is not ready yet."
        exit 1
    fi
else
    echo -e "${YELLOW}[WARN]${NC} pg_isready command not found, skipping deep check."
    echo "STATUS: SUCCESS (basic check passed)"
    exit 0
fi
