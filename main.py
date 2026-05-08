from fastapi import FastAPI, BackgroundTasks, HTTPException
import subprocess
import os
from typing import Optional
from pydantic import BaseModel

app = FastAPI(title="AI Library Script Center API")

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
ENGINE_PATH = os.path.join(PROJECT_ROOT, "engine.sh")

class InstallRequest(BaseModel):
    module: str
    version: Optional[str] = None

@app.get("/")
def read_root():
    return {"message": "Welcome to AI Library Script Center", "status": "online"}

@app.get("/modules")
def list_modules():
    modules_dir = os.path.join(PROJECT_ROOT, "modules")
    modules = [d for d in os.listdir(modules_dir) if os.path.isdir(os.path.join(modules_dir, d))]
    return {"modules": modules}

@app.get("/check/{module}")
def check_module(module: str):
    """
    驗證特定模組或使用 'all' 驗證全部
    """
    try:
        result = subprocess.run(
            ["bash", ENGINE_PATH, module, "check"],
            capture_output=True, text=True
        )
        return {
            "module": module,
            "success": result.returncode == 0,
            "output": result.stdout,
            "error": result.stderr
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def run_install_task(module: str, version: Optional[str]):
    """
    背景執行的安裝任務
    """
    cmd = ["bash", ENGINE_PATH, module, "setup"]
    if version:
        cmd.append(version)
    
    # 這裡可以將結果導向特定資料庫或檔案，方便前端查詢進度
    subprocess.run(cmd, capture_output=True)

@app.post("/install")
def install_module(request: InstallRequest, background_tasks: BackgroundTasks):
    """
    觸發安裝任務 (非同步背景執行)
    """
    # 檢查模組目錄是否存在
    module_path = os.path.join(PROJECT_ROOT, "modules", request.module)
    if not os.path.exists(module_path) and request.module != "all":
        raise HTTPException(status_code=404, detail="Module not found")

    background_tasks.add_task(run_install_task, request.module, request.version)
    
    return {
        "message": f"Installation of {request.module} started in background.",
        "status": "processing"
    }

@app.get("/versions")
def get_versions():
    """
    讀取目前版本資料庫
    """
    db_path = os.path.join(PROJECT_ROOT, "versions.db")
    if not os.path.exists(db_path):
        return {"versions": []}
    
    versions = []
    with open(db_path, "r") as f:
        for line in f:
            if "|" in line:
                parts = line.strip().split("|")
                versions.append({
                    "module": parts[0],
                    "version": parts[1],
                    "status": parts[2],
                    "updated_at": parts[3]
                })
    return {"versions": versions}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
