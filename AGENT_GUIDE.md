# AI Agent Development Guide: Module Standardization

This guide is for AI Agents (like Gemini, GPT, or Claude) to understand how to autonomously extend the **AI Library** framework. Follow these rules strictly to ensure compatibility and system integrity.

## 🏗️ Framework Architecture Overview
The system follows a "Core Engine + Independent Modules" pattern:
- `/engine.sh`: Central executor.
- `/versions.db`: Central version registry.
- `/modules/{module_name}/`: Each software gets its own folder containing `setup.sh` and `check.sh`.

---

## 🛠️ Standards for `setup.sh` (Installation Logic)
When generating a `setup.sh` for a new module:

1. **Safety First**: Always start with `set -e` to stop on any error.
2. **Version Retrieval**:
   - Always read the target version from the registry using: 
     `VERSION=$(grep "^{module_name}|" "../../versions.db" | cut -d'|' -f2)`
3. **Ubuntu 24.04 (Noble) Best Practices**:
   - Use `/etc/apt/keyrings/` for GPG keys (not the deprecated `apt-key`).
   - Use `$(lsb_release -cs)` or `$(. /etc/os-release && echo "$VERSION_CODENAME")` to detect the distribution name.
4. **Idempotency**: Ensure the script can run multiple times without causing side effects (e.g., check if a repo is already added).
5. **Final Message**: Print a clear success message including the installed version.

---

## 🔍 Standards for `check.sh` (Verification Logic)
When generating a `check.sh` for a new module:

1. **Functional Check**: Use commands like `systemctl is-active`, `ss -tuln`, or `{binary} --version` to verify the installation.
2. **Standardized Output**:
   - If successful, the script MUST print `STATUS: SUCCESS`.
   - If failed, the script MUST print `STATUS: FAILED`.
3. **Exit Codes**: Return `0` for success and non-zero for failure.

---

## 📊 Version Registry Protocol (`versions.db`)
When a new module is created, the AI Agent must ensure an entry exists in the root `versions.db`:

- **Format**: `module_name | version | status | last_updated`
- **Initial Status**: `inactive`
- **Initial Date**: `never`

---

## 🤖 Instructions for AI Agents
If you are asked to "Add a new module" (e.g., Redis, Nginx):
1. **Research**: Find the official installation method for Ubuntu 24.04.
2. **Implement**: Create the directory and write both `setup.sh` and `check.sh` using the standards above.
3. **Register**: Update the `versions.db` file.
4. **Finalize**: Use `chmod +x` to ensure all scripts are executable.

---

**End of Guide**
