#!/bin/bash

# =================================================================
# setup_ai_lib.sh - AI 函式庫自動化環境初始化腳本
# =================================================================

# 1. 定義基礎參數
BASE_PATH="/opt/ai-library"
SUB_DIRS=("configs" "modules" "logs")
VERSION_FILE="$BASE_PATH/versions.db"

echo ">>> 開始執行環境初始化..."

# 2. 檢查並建立目錄結構
echo "[1/4] 檢查目錄結構..."
if [ ! -d "$BASE_PATH" ]; then
    echo "    - 建立根目錄: $BASE_PATH"
    sudo mkdir -p "$BASE_PATH"
else
    echo "    - 根目錄已存在: $BASE_PATH"
fi

for dir in "${SUB_DIRS[@]}"; do
    TARGET_DIR="$BASE_PATH/$dir"
    if [ ! -d "$TARGET_DIR" ]; then
        echo "    - 建立子目錄: $TARGET_DIR"
        sudo mkdir -p "$TARGET_DIR"
    else
        echo "    - 子目錄已存在: $TARGET_DIR"
    fi
done

# 3. 權限賦予
echo "[2/4] 配置權限..."
# 將目錄擁有者設為目前使用者
sudo chown -R $USER:$USER "$BASE_PATH"
# 設定標準目錄權限 (755: 擁有者讀寫執行, 其他人讀執行)
chmod -R 755 "$BASE_PATH"
echo "    - 權限配置完成。"

# 4. 寫入基礎版本定義
echo "[3/4] 初始化版本定義..."
if [ ! -f "$VERSION_FILE" ] || [ ! -s "$VERSION_FILE" ]; then
    cat <<EOF > "$VERSION_FILE"
# AI Library Version Registry
# Created: $(date '+%Y-%m-%d %H:%M:%S')
# Schema: component_name | version | status | last_updated

system_core|1.0.0|active|$(date '+%Y-%m-%d')
config_manager|1.0.0|active|$(date '+%Y-%m-%d')
module_loader|1.0.0|active|$(date '+%Y-%m-%d')
EOF
    echo "    - 已建立基礎版本檔案: $VERSION_FILE"
else
    echo "    - 版本檔案已存在，跳過寫入以保護現有數據。"
fi

# 5. 腳本自身權限優化
echo "[4/4] 優化腳本執行權限..."
chmod +x "$0"
if [ -f "init_structure.sh" ]; then chmod +x init_structure.sh; fi

echo ">>> 初始化成功！您的 AI 函式庫環境已就緒。"
echo ">>> 目錄位置: $BASE_PATH"
