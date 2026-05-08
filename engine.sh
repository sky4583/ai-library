#!/bin/bash

# =================================================================
# AI Library Core Engine (engine.sh)
# 用法: ./engine.sh [模組名稱] [執行動作: setup|check] [版本指定 (選填)]
# =================================================================

PROJECT_ROOT=$(pwd)
LOG_FILE="$PROJECT_ROOT/logs/engine.log"
VERSION_DB="$PROJECT_ROOT/versions.db"

# ... (顏色定義與 log 函數保持不變)

usage() {
    echo "用法: $0 [module_name] [setup|check] [version_override (optional)]"
    echo "可用模組:"
    ls -d modules/*/ | cut -f2 -d'/'
    exit 1
}

# 檢查參數
if [ "$#" -lt 2 ]; then
    usage
fi

MODULE=$1
ACTION=$2
VERSION_OVERRIDE=$3

# 將版本覆蓋匯出為環境變數，讓子腳本可以優先讀取
export TARGET_VERSION=$VERSION_OVERRIDE
SCRIPT_PATH="$PROJECT_ROOT/modules/$MODULE/$ACTION.sh"

# 檢查模組與動作是否存在
if [ ! -f "$SCRIPT_PATH" ]; then
    log "${RED}錯誤${NC}" "找不到腳本: $SCRIPT_PATH"
    exit 1
fi

log "${YELLOW}執行${NC}" "開始執行模組 [$MODULE] 的動作 [$ACTION]..."

# 執行腳本
bash "$SCRIPT_PATH"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log "${GREEN}完成${NC}" "模組 [$MODULE] 動作 [$ACTION] 執行成功。"
    
    # 如果是 setup 成功，更新版本庫 (範例邏輯)
    if [ "$ACTION" == "setup" ]; then
        # 簡單的版本更新邏輯，這裡可以根據需求更精細化
        sed -i "s/^$MODULE|.*$/$MODULE|$(date +%Y%m%d)|active|$(date +%Y-%m-%d)/" "$VERSION_DB"
    fi
else
    log "${RED}失敗${NC}" "模組 [$MODULE] 動作 [$ACTION] 傳回錯誤代碼: $EXIT_CODE"
    exit $EXIT_CODE
fi
