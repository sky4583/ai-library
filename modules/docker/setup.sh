#!/bin/bash

# =================================================================
# Docker setup module for Ubuntu 24.04 (Noble Numbat)
# Path: modules/docker/setup.sh
# =================================================================

set -e 

# 1. 取得目標版本
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的 Docker 覆蓋版本: $VERSION"
else
    VERSION="latest"
    echo ">>> 使用預設 Docker 版本: $VERSION"
fi

# 定義顏色
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}>>> 開始安裝 Docker 模組 (Ubuntu 24.04)...${NC}"

# 2. 環境清理：移除舊版或衝突套件 (防止互動式衝突)
echo "正在清理舊版 Docker 相關套件..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# 3. 更新系統並安裝基礎工具
echo "更新系統並安裝基礎依賴..."
sudo apt-get update -y
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ca-certificates curl gnupg

# 4. 設定 Docker 官方 GPG 金鑰
echo "配置 Docker GPG 金鑰..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 5. 加入 Docker Repository
echo "新增 Docker 軟體源..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6. 安裝 Docker 套件 (使用靜默參數)
echo "安裝 Docker Engine, CLI 及 Compose 插件..."
sudo apt-get update -y
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 7. 配置使用者群組
echo "配置 Docker 使用者群組..."
if ! getent group docker > /dev/null; then
    sudo groupadd docker
fi
sudo usermod -aG docker $USER

# 8. 啟動服務
echo "設定 Docker 服務..."
sudo systemctl enable docker
sudo systemctl start docker

echo -e "${GREEN}>>> Docker 安裝完成！${NC}"
