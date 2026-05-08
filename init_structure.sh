#!/bin/bash
# init_structure.sh - 自動建置腳本資料庫結構

BASE_PATH="/opt/ai-library"

echo "正在建置腳本資料庫結構於 $BASE_PATH ..."

# 建立核心目錄
sudo mkdir -p $BASE_PATH/configs
sudo mkdir -p $BASE_PATH/modules
sudo mkdir -p $BASE_PATH/logs

# 建立全域版本庫（如果不存在）
if [ ! -f "$BASE_PATH/versions.db" ]; then
    sudo touch $BASE_PATH/versions.db
    echo "已建立 versions.db"
fi

# 修正權限
sudo chown -R $USER:$USER $BASE_PATH
chmod +x *.sh

echo "結構建置完成！"
