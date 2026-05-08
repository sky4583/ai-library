#!/bin/bash

# =================================================================
# Docker setup module for Ubuntu 24.04 (Noble Numbat)
# Path: modules/docker/setup.sh
# =================================================================

set -e # 遇到錯誤即停止執行

# 1. 取得目標版本 (Docker 通常安裝 latest，但保留覆蓋彈性)
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的 Docker 覆蓋版本: $VERSION"
else
    VERSION="latest"
    echo ">>> 使用預設 Docker 版本: $VERSION"
fi

# 定義顏色用於日誌輸出
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}>>> 開始安裝 Docker 模組 (Ubuntu 24.04)...${NC}"

# 2. 更新系統軟體源並安裝基礎工具
echo "更新系統並安裝基礎依賴..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

# 3. 設定 Docker 官方 GPG 金鑰
echo "配置 Docker GPG 金鑰..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 4. 加入 Docker Repository 到 APT sources
echo "新增 Docker 軟體源..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. 安裝 Docker 套件
echo "安裝 Docker Engine, CLI 及 Compose 插件..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. 配置使用者群組 (免 sudo 執行 docker)
echo "配置 Docker 使用者群組..."
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER

# 7. 啟動並設定開機自啟
echo "設定 Docker 服務..."
sudo systemctl enable docker
sudo systemctl start docker

# 8. 驗證安裝
echo -e "${GREEN}>>> Docker 安裝完成！${NC}"
docker --version
docker compose version

echo -e "注意：請重新登入或執行 'newgrp docker' 以套用免 sudo 權限。"
