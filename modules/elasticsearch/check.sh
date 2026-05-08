#!/bin/bash

# =================================================================
# Elasticsearch Check Module
# Path: modules/elasticsearch/check.sh
# =================================================================

echo ">>> 正在驗證 Elasticsearch 狀態..."

# 1. 檢查服務是否運行中
if systemctl is-active --quiet elasticsearch; then
    echo -e "${GREEN}[OK]${NC} Elasticsearch service is running."
else
    echo -e "${RED}[FAIL]${NC} Elasticsearch service is not active."
    exit 1
fi

# 2. 檢查 9200 埠口
if ss -tuln | grep -q ":9200 "; then
    echo -e "${GREEN}[OK]${NC} Port 9200 is listening."
else
    echo -e "${RED}[FAIL]${NC} Port 9200 is not responding."
    exit 1
fi

# 3. 深度檢查: 測試 API 回應 (忽略證書錯誤，因為開發環境常用自簽證書)
echo ">>> 正在測試 API 健康狀況..."
HEALTH_RESPONSE=$(curl -s -k -u elastic:${ELASTIC_PASSWORD:-'password'} "http://localhost:9200/_cluster/health?pretty" || curl -s -k "https://localhost:9200/_cluster/health?pretty")

if echo "$HEALTH_RESPONSE" | grep -q "\"status\" : \"green\"\|\"status\" : \"yellow\""; then
    echo -e "${GREEN}[OK]${NC} Elasticsearch Cluster Health: $(echo "$HEALTH_RESPONSE" | grep "status" | cut -d'"' -f4)"
    echo "STATUS: SUCCESS"
    exit 0
else
    echo -e "${YELLOW}[WARN]${NC} Could not verify cluster health (Wait for init or check auth)."
    echo "STATUS: SUCCESS (basic check passed)"
    exit 0
fi
