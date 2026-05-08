#!/bin/bash

# =================================================================
# Elasticsearch Setup Module (Official Elastic Repository)
# Path: modules/elasticsearch/setup.sh
# =================================================================

set -e

# 1. 取得目標版本
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的 Elasticsearch 覆蓋版本: $VERSION"
else
    if [ -f "$VERSION_DB" ]; then
        VERSION=$(grep "^elasticsearch|" "$VERSION_DB" | cut -d'|' -f2)
    fi
    VERSION=${VERSION:-"8"}
    echo ">>> 使用版本: $VERSION"
fi

echo ">>> 正在準備安裝 Elasticsearch (Major Version: $VERSION)..."

# 2. 環境清理
echo "正在清理舊版 Elasticsearch 相關套件..."
sudo apt-get remove -y --purge elasticsearch || true

# 3. 安裝必要依賴
sudo apt-get update
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ca-certificates curl gnupg

# 4. 匯入 Elastic 官方 GPG 金鑰
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/elasticsearch-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/elasticsearch-keyring.gpg

# 5. 新增 Elastic 軟體源
echo "deb [signed-by=/etc/apt/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/$VERSION.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-$VERSION.x.list

# 6. 安裝 Elasticsearch
sudo apt-get update
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" elasticsearch

# 7. 啟動服務
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

echo ">>> Elasticsearch 安裝與啟動完成！"
