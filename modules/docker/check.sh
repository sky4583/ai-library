#!/bin/bash

# =================================================================
# Docker Check Module
# Path: modules/docker/check.sh
# =================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo ">>> 正在驗證 Docker 狀態..."

# 1. 檢查二進位檔案是否存在
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} Docker 已安裝: $(docker --version)"
else
    echo -e "${RED}[FAIL]${NC} 找不到 Docker 指令"
    exit 1
fi

# 2. 檢查 Docker 服務是否運行中
if systemctl is-active --quiet docker; then
    echo -e "${GREEN}[OK]${NC} Docker 服務正在執行中"
else
    echo -e "${RED}[FAIL]${NC} Docker 服務未啟動"
    exit 1
fi

# 3. 檢查目前使用者權限 (測試免 sudo)
if docker ps >/dev/null 2>&1; then
    echo -e "${GREEN}[OK]${NC} 目前使用者具備 Docker 執行權限"
    echo -e "${GREEN}STATUS: SUCCESS${NC}"
    exit 0
else
    echo -e "${RED}[WARN]${NC} 無法存取 Docker Socket，可能需要重新登入或使用 sudo"
    exit 2
fi
