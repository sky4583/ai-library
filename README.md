# AI Library - 模組化自動化腳本資料庫

這是一個基於 Ubuntu 24.04 的自動化腳本管理系統，專為「後端管理者建置、前端使用者執行」的協作流程而設計。

---

## 🏗️ 專案架構概覽

```text
/ai-library/
├── engine.sh                # [前端] 核心執行引擎 (支援動態版本覆蓋)
├── deploy.sh                # [前端] 遠端部署工具 (支援跨主機派送)
├── versions.db              # [全域] 版本註冊表 (預設版本定義)
├── modules/                 # [模組] 獨立腳本庫
│   └── {module_name}/       # setup.sh, check.sh
├── AGENT_GUIDE.md           # [後端] AI 開發規範 (給 AI Agent 讀的憲法)
├── add_module.sh            # [後端] 模組生成輔助工具
├── setup_ai_lib.sh          # [管理者] 環境初始化工具
└── logs/                    # [系統] 執行日誌
```

---

## 🛠️ 後端管理者指南 (Administrator)

管理者負責系統架構的維護、新模組的開發規範與版本控管。

### 1. 系統初始化
第一次部署環境時，請執行初始化腳本以建置目錄與權限：
```bash
bash setup_ai_lib.sh
```

### 2. 管理模組開發
- **自動化新增**：使用 `add_module.sh` 快速產出符合規範的模組骨架。
- **規範執行**：確保所有新產出的腳本遵循 `AGENT_GUIDE.md`。
- **動態版本邏輯**：在編寫 `setup.sh` 時，務必優先判斷 `$TARGET_VERSION` 環境變數，以支援使用者的動態需求。

---

## 🚀 前端使用者 / AI Agent 指南 (User)

使用者可根據需求選擇「預設版本」或「指定版本」進行安裝。

### 1. 軟體部署 (Setup)
- **使用預設版本** (定義於 `versions.db`):
  ```bash
  bash engine.sh nginx setup
  ```
- **使用指定版本** (動態覆蓋):
  ```bash
  bash engine.sh nginx setup 1.24
  ```

### 2. 遠端派送 (Deploy)
同樣支援動態版本指定：
```bash
# 語法: bash deploy.sh [目標IP] [模組] [動作] [版本(選填)]
bash deploy.sh 192.168.1.100 node setup 18
```

### 3. 狀態驗證 (Check)
```bash
bash engine.sh postgresql check
```

---

## 🌐 跨主機管轄規範 (Multi-Host Governance)

- **SSH Key 授權**：控制中心必須預先將 SSH Public Key 部署至所有受控端的 `authorized_keys`。
- **免密碼 Sudo**：受控端使用者建議配置 `NOPASSWD` sudo 權限。
- **環境要求**：Ubuntu 24.04 LTS，需預裝 `rsync` 與 `bash`。

---

## 📝 技術規範補充
- **版本優先級**：`命令列指定 (TARGET_VERSION)` > `全域註冊表 (versions.db)`。
- **日誌追蹤**：所有執行記錄皆存放在 `logs/engine.log`。
