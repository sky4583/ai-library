#!/bin/bash

# =================================================================
# Nginx Setup Module (Official Repository)
# Path: modules/nginx/setup.sh
# =================================================================

set -e

# 1. 取得目標版本
if [ -n "$TARGET_VERSION" ]; then
    VERSION="$TARGET_VERSION"
    echo ">>> 使用前端指定的覆蓋版本: $VERSION"
else
    VERSION="latest"
    echo ">>> 使用預設版本: latest"
fi

# 2. 環境清理：移除舊版或衝突套件
echo "正在清理舊版 Nginx 相關套件..."
sudo apt-get remove -y --purge nginx nginx-common nginx-full || true

# 3. 安裝必要依賴
sudo apt-get update
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    curl gnupg2 ca-certificates lsb-release ubuntu-keyring

# 4. 匯入 Nginx 官方 GPG 金鑰
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /etc/apt/keyrings/nginx-archive-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/nginx-archive-keyring.gpg

# 5. 新增 Nginx 官方軟體源
echo "deb [signed-by=/etc/apt/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

# 6. 安裝 Nginx (使用靜默參數)
sudo apt-get update
if [ "$VERSION" == "latest" ]; then
    sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" nginx
else
    FULL_VER=$(apt-cache madison nginx | grep "$VERSION" | head -n 1 | awk '{print $3}')
    if [ -n "$FULL_VER" ]; then
        echo ">>> 找到符合的版本: $FULL_VER"
        sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "nginx=$FULL_VER"
    else
        echo ">>> [警告] 找不到版本 $VERSION，嘗試直接安裝..."
        sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "nginx=$VERSION" || sudo apt-get install -y nginx
    fi
fi

# 7. 啟動服務
sudo systemctl enable nginx
sudo systemctl start nginx

echo ">>> Nginx 安裝與啟動完成！"
