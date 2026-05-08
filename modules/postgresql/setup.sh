#!/bin/bash

# =================================================================
# PostgreSQL Setup Module
# Path: modules/postgresql/setup.sh
# =================================================================

set -e

# 1. 取得目標版本 (優先使用環境變數中的覆蓋值，其次讀取資料庫)
if [ -n "$TARGET_VERSION" ]; then
    PG_VER="$TARGET_VERSION"
    echo ">>> 使用前端指定的 PostgreSQL 覆蓋版本: $PG_VER"
else
    VERSION_DB="../../versions.db"
    if [ -f "$VERSION_DB" ]; then
        PG_VER=$(grep "^postgresql|" "$VERSION_DB" | cut -d'|' -f2)
    else
        PG_VER="16" # 預設值
    fi
    echo ">>> 使用資料庫預設 PostgreSQL 版本: $PG_VER"
fi

echo ">>> 開始安裝 PostgreSQL $PG_VER..."

# 2. 安裝官方 PGDG 源
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg
sudo chmod a+r /etc/apt/keyrings/postgresql.gpg

# 3. 新增 Repository
echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# 4. 安裝 PostgreSQL
sudo apt-get update
sudo apt-get install -y "postgresql-$PG_VER"

# 5. 啟動服務
sudo systemctl enable postgresql
sudo systemctl start postgresql

echo ">>> PostgreSQL $PG_VER 安裝完成！"
