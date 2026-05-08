#!/bin/bash

# =================================================================
# PostgreSQL Setup Module
# Path: modules/postgresql/setup.sh
# =================================================================

set -e

# 1. 取得目標版本
if [ -n "$TARGET_VERSION" ]; then
    PG_VER="$TARGET_VERSION"
    echo ">>> 使用前端指定的 PostgreSQL 覆蓋版本: $PG_VER"
else
    if [ -f "$VERSION_DB" ]; then
        PG_VER=$(grep "^postgresql|" "$VERSION_DB" | cut -d'|' -f2)
    fi
    PG_VER=${PG_VER:-"16"}
    echo ">>> 使用版本: $PG_VER"
fi

echo ">>> 開始安裝 PostgreSQL $PG_VER..."

# 2. 環境清理
echo "正在清理舊版 PostgreSQL 相關套件..."
sudo apt-get remove -y --purge postgresql* || true

# 3. 安裝官方 PGDG 源
sudo apt-get update
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/postgresql.gpg
sudo chmod a+r /etc/apt/keyrings/postgresql.gpg

# 4. 新增 Repository
echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# 5. 安裝 PostgreSQL
sudo apt-get update
sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "postgresql-$PG_VER"

# 6. 啟動服務
sudo systemctl enable postgresql
sudo systemctl start postgresql

echo ">>> PostgreSQL $PG_VER 安裝完成！"
