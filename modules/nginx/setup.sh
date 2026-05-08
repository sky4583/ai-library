#!/bin/bash

# =================================================================
# Nginx Setup Module (Official Repository)
# Path: modules/nginx/setup.sh
# =================================================================

set -e

# 1. 取得目標版本 (優先使用環境變數中的覆蓋值，其次讀取資料庫)
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的覆蓋版本: $VERSION"
else
    VERSION=$(grep "^nginx|" "../../versions.db" | cut -d'|' -f2)
    echo ">>> 使用資料庫預設版本: $VERSION"
fi

# 2. 安裝必要依賴
sudo apt-get update
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# 3. 匯入 Nginx 官方 GPG 金鑰 (遵照 AGENT_GUIDE.md 使用 /etc/apt/keyrings)
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /etc/apt/keyrings/nginx-archive-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/nginx-archive-keyring.gpg

# 4. 新增 Nginx 官方軟體源
echo "deb [signed-by=/etc/apt/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# 5. 安裝 Nginx
sudo apt-get update
if [ "$VERSION" == "latest" ]; then
    sudo apt-get install -y nginx
else
    # 搜尋符合版本開頭的完整版本號 (例如 1.26 -> 1.26.1-1~noble)
    FULL_VER=$(apt-cache madison nginx | grep "$VERSION" | head -n 1 | awk '{print $3}')
    if [ -n "$FULL_VER" ]; then
        echo ">>> 找到符合的版本: $FULL_VER"
        sudo apt-get install -y "nginx=$FULL_VER"
    else
        echo ">>> [警告] 找不到版本 $VERSION，嘗試直接安裝..."
        sudo apt-get install -y "nginx=$VERSION" || sudo apt-get install -y nginx
    fi
fi

# 6. 啟動並設定開機自啟
sudo systemctl enable nginx
sudo systemctl start nginx

echo ">>> Nginx 安裝與啟動完成！"
