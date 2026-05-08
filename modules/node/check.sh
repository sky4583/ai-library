#!/bin/bash

# =================================================================
# Node.js Check Module
# Path: modules/node/check.sh
# =================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo ">>> 正在驗證 Node.js 狀態..."

# 1. 檢查 node 指令
if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} Node.js binary found: $(node -v)"
else
    echo -e "${RED}[FAIL]${NC} Node.js command not found."
    exit 1
fi

# 2. 檢查 npm 指令
if command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} npm binary found: $(npm -v)"
    echo -e "${GREEN}STATUS: SUCCESS${NC}"
    exit 0
else
    echo -e "${RED}[FAIL]${NC} npm command not found."
    exit 1
fi
