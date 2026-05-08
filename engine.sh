#!/bin/bash

# =================================================================
# AI Library Core Engine (engine.sh)
# 用法: ./engine.sh [模組名稱] [執行動作: setup|check] [版本指定 (選填)]
# =================================================================

PROJECT_ROOT=$(pwd)
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/engine.log"
VERSION_DB="$PROJECT_ROOT/versions.db"

# 確保日誌目錄與版本資料庫存在
mkdir -p "$LOG_DIR"
touch "$VERSION_DB"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local level=$1
    local msg=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "[$timestamp] $level $msg" | tee -a "$LOG_FILE"
}

usage() {
    echo "用法: $0 [module_name|all] [setup|check] [version_override (optional)]"
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

# 支援 "all" 檢查
if [ "$MODULE" == "all" ] && [ "$ACTION" == "check" ]; then
    log "${BLUE}資訊${NC}" "執行全系統狀態檢查..."
    for mod_path in modules/*/; do
        mod=$(basename "$mod_path")
        if [ -f "modules/$mod/check.sh" ]; then
            bash "modules/$mod/check.sh"
        fi
    done
    exit 0
fi

# 將版本覆蓋匯出為環境變數
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
    
    # 更新版本庫
    if [ "$ACTION" == "setup" ]; then
        CURRENT_DATE=$(date +%Y-%m-%d)
        VERSION_STR="${VERSION_OVERRIDE:-"latest"}"
        
        if grep -q "^$MODULE|" "$VERSION_DB"; then
            sed -i "s/^$MODULE|.*$/$MODULE|$VERSION_STR|active|$CURRENT_DATE/" "$VERSION_DB"
        else
            echo "$MODULE|$VERSION_STR|active|$CURRENT_DATE" >> "$VERSION_DB"
        fi
        log "${BLUE}資料庫${NC}" "已更新 $VERSION_DB 中的 $MODULE 資訊。"
    fi
else
    log "${RED}失敗${NC}" "模組 [$MODULE] 動作 [$ACTION] 傳回錯誤代碼: $EXIT_CODE"
    exit $EXIT_CODE
fi
