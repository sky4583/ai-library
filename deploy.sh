#!/bin/bash

# =================================================================
# AI Library Remote Deployer (deploy.sh)
# 用法: ./deploy.sh [遠端主機IP/別名] [模組名稱] [執行動作]
# 範例: ./deploy.sh 192.168.1.100 docker setup
# =================================================================

if [ "$#" -lt 3 ]; then
    echo "用法: $0 [target_ip] [module_name] [action] [version (optional)]"
    exit 1
fi

TARGET_HOST=$1
MODULE=$2
ACTION=$3
VERSION_OVERRIDE=$4

# ... (rsync 部分保持不變)

# 3. 執行遠端命令 (加入第四個參數 VERSION_OVERRIDE)
echo ">>> 正在遠端執行模組 [$MODULE] 的動作 [$ACTION] (版本: ${VERSION_OVERRIDE:-預設})..."
ssh -t "$TARGET_HOST" "cd /tmp/ai-library && bash engine.sh $MODULE $ACTION $VERSION_OVERRIDE"

# 4. 回傳執行結果
if [ $? -eq 0 ]; then
    echo ">>> [成功] 遠端任務執行完畢。"
else
    echo ">>> [失敗] 遠端任務執行失敗。"
    exit 1
fi
