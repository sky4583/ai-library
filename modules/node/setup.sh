#!/bin/bash

# =================================================================
# Node.js Setup Module (NodeSource Repository)
# Path: modules/node/setup.sh
# =================================================================

set -e

# 1. 取得目標版本 (優先使用環境變數中的覆蓋值，其次讀取資料庫)
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的 Node.js 覆蓋版本: $VERSION"
else
    VERSION=$(grep "^node|" "../../versions.db" | cut -d'|' -f2)
    echo ">>> 使用資料庫預設 Node.js 版本: $VERSION"
fi

echo ">>> 正在準備安裝 Node.js (Major Version: $VERSION)..."

# 2. 安裝必要依賴
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 3. 匯入 NodeSource GPG 金鑰 (遵照 AGENT_GUIDE.md 使用 /etc/apt/keyrings)
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
sudo chmod a+r /etc/apt/keyrings/nodesource.gpg

# 4. 新增 NodeSource 軟體源
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$VERSION.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# 5. 安裝 Node.js
sudo apt-get update
sudo apt-get install -y nodejs

# 6. 驗證安裝結果
echo ">>> Node.js 安裝完成！"
node -v
npm -v
