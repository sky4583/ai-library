#!/bin/bash

# =================================================================
# Elasticsearch Setup Module (Official Elastic Repository)
# Path: modules/elasticsearch/setup.sh
# =================================================================

set -e

# 1. 取得目標版本 (優先使用環境變數中的覆蓋值，其次讀取資料庫)
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的 Elasticsearch 覆蓋版本: $VERSION"
else
    VERSION=$(grep "^elasticsearch|" "../../versions.db" | cut -d'|' -f2)
    echo ">>> 使用資料庫預設 Elasticsearch 版本: $VERSION"
fi

echo ">>> 正在準備安裝 Elasticsearch (Major Version: $VERSION)..."

# 2. 安裝必要依賴
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 3. 匯入 Elastic 官方 GPG 金鑰 (遵照 AGENT_GUIDE.md 使用 /etc/apt/keyrings)
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /etc/apt/keyrings/elasticsearch-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/elasticsearch-keyring.gpg

# 4. 新增 Elastic 軟體源 (根據版本號，例如 8.x)
echo "deb [signed-by=/etc/apt/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/$VERSION.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-$VERSION.x.list

# 5. 安裝 Elasticsearch
sudo apt-get update
sudo apt-get install -y elasticsearch

# 6. 啟動並設定開機自啟
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

echo ">>> Elasticsearch 安裝與啟動完成！"
echo "注意：預設密碼與認證 Token 會在第一次啟動時產生於日誌中，或使用 'bin/elasticsearch-reset-password -u elastic' 重設。"
