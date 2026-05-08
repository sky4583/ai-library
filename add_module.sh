#!/bin/bash

# =================================================================
# Improved Module Creator (add_module.sh)
# Usage: ./add_module.sh [module_name] [version (optional)]
# =================================================================

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [module_name] [version (optional)]"
    exit 1
fi

MODULE_NAME=$1
# 如果沒指定版本，預設設為 "latest"
VERSION=${2:-"latest"}
PROJECT_ROOT=$(pwd)
MODULE_DIR="$PROJECT_ROOT/modules/$MODULE_NAME"
VERSION_DB="$PROJECT_ROOT/versions.db"

echo ">>> Creating module: $MODULE_NAME (Default Version: $VERSION)..."

# 1. 建立目錄
mkdir -p "$MODULE_DIR"

# 2. 產生 setup.sh 模板 (具備智慧版本處理)
cat <<EOF > "$MODULE_DIR/setup.sh"
#!/bin/bash
# $MODULE_NAME Setup Script
set -e

# 從 versions.db 取得版本
DB_VER=\$(grep "^$MODULE_NAME|" "../../versions.db" | cut -d'|' -f2)

if [ "\$DB_VER" == "latest" ]; then
    echo ">>> Installing latest version of $MODULE_NAME..."
    # 範例：sudo apt-get update && sudo apt-get install -y $MODULE_NAME
else
    echo ">>> Installing $MODULE_NAME version: \$DB_VER..."
    # 範例：sudo apt-get update && sudo apt-get install -y $MODULE_NAME=\$DB_VER
fi

echo ">>> $MODULE_NAME installation complete!"
EOF

# 3. 產生 check.sh 模板
cat <<EOF > "$MODULE_DIR/check.sh"
#!/bin/bash
# $MODULE_NAME Check Script

echo ">>> Verifying $MODULE_NAME..."
if command -v $MODULE_NAME >/dev/null 2>&1; then
    echo "[OK] $MODULE_NAME is installed."
    echo "STATUS: SUCCESS"
    exit 0
else
    echo "[FAIL] $MODULE_NAME command not found."
    echo "STATUS: FAILED"
    exit 1
fi
EOF

# 4. 註冊到版本庫
if ! grep -q "^$MODULE_NAME|" "$VERSION_DB"; then
    echo "$MODULE_NAME|$VERSION|inactive|never" >> "$VERSION_DB"
    echo "    - Added to versions.db"
fi

chmod +x "$MODULE_DIR/"*.sh

echo ">>> Module [$MODULE_NAME] created successfully!"
echo ">>> NOTE: Please edit $MODULE_NAME/setup.sh to add specific repo/GPG keys if needed."
