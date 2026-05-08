#!/bin/bash

# =================================================================
# Node.js Check Module
# Path: modules/node/check.sh
# =================================================================

echo ">>> 正在驗證 Node.js 狀態..."

# 1. 檢查 node 指令
if command -v node >/dev/null 2>&1; then
    echo "[OK] Node.js binary found: $(node -v)"
else
    echo "[FAIL] Node.js command not found."
    echo "STATUS: FAILED"
    exit 1
fi

# 2. 檢查 npm 指令
if command -v npm >/dev/null 2>&1; then
    echo "[OK] npm binary found: $(npm -v)"
else
    echo "[FAIL] npm command not found."
    echo "STATUS: FAILED"
    exit 1
fi

echo "STATUS: SUCCESS"
exit 0
