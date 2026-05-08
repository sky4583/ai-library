#!/bin/bash

# =================================================================
# Node.js Setup Module (NodeSource Repository)
# Path: modules/node/setup.sh
# =================================================================

set -e

# 1. 取得目標版本
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的 Node.js 覆蓋版本: $VERSION"
else
    if [ -f "$VERSION_DB" ]; then
        VERSION=$(grep "^node|" "$VERSION_DB" | cut -d'|' -f2)
    fi
    VERSION=${VERSION:-"20"}
    echo ">>> 使用版本: $VERSION"
fi

echo ">>> 正在準備安裝 Node.js (Major Version: $VERSION)..."

# 2. 環境清理
echo "正在清理舊版 Node.js/npm 相關套件..."
sudo apt-get remove -y nodejs npm || true

# 3. 安裝必要依賴
sudo apt-get update
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ca-certificates curl gnupg

# 4. 匯入 NodeSource GPG 金鑰
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/nodesource.gpg
sudo chmod a+r /etc/apt/keyrings/nodesource.gpg

# 5. 新增 NodeSource 軟體源
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$VERSION.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# 6. 安裝 Node.js
sudo apt-get update
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" nodejs

echo ">>> Node.js 安裝完成！"
