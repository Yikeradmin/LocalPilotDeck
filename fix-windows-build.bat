@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ═══════════════════════════════════════════════════════════════════
echo   PilotDeck Windows 构建修复工具
echo ═══════════════════════════════════════════════════════════════════
echo.

set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

echo [1/4] 检查 edgeclaw-memory-core 构建状态...

set "EDGECLAW_DIR=%PROJECT_ROOT%\src\context\memory\edgeclaw-memory-core"

if not exist "%EDGECLAW_DIR%\lib" (
    echo 构建 edgeclaw-memory-core...
    cd /d "%EDGECLAW_DIR%"
    call npx tsc -p tsconfig.json
    cd /d "%PROJECT_ROOT%"
)

if exist "%EDGECLAW_DIR%\lib\index.js" (
    echo ✓ edgeclaw-memory-core 已构建
) else (
    echo 错误: edgeclaw-memory-core 构建失败
    pause
    exit /b 1
)

echo.
echo [2/4] 修复 node_modules 链接...

:: 检查 pnpm 是否正确链接了 edgeclaw-memory-core
if exist "node_modules\edgeclaw-memory-core\lib\index.js" (
    echo ✓ node_modules 链接正常
    goto :build
)

echo 修复 edgeclaw-memory-core 链接...

:: 删除旧链接
if exist "node_modules\edgeclaw-memory-core" (
    rmdir "node_modules\edgeclaw-memory-core" 2>nul
)

:: 使用 junction 创建链接 (Windows 不需要管理员权限)
mklink /J "node_modules\edgeclaw-memory-core" "%EDGECLAW_DIR%"

if errorlevel 1 (
    echo 错误: 无法创建链接
    echo.
    echo 尝试备用方案: 直接复制文件...
    xcopy /e /i /q "%EDGECLAW_DIR%" "node_modules\edgeclaw-memory-core" >nul
)

echo ✓ 链接已修复

:build
echo.
echo [3/4] 构建后端...

cd /d "%PROJECT_ROOT%"
call npx tsc -p tsconfig.json

if errorlevel 1 (
    echo 错误: 后端构建失败
    pause
    exit /b 1
)

:: 复制 builtin plugins
if exist "src\extension\plugins\builtin" (
    if not exist "dist\src\extension\plugins\builtin" (
        xcopy /e /i /q "src\extension\plugins\builtin" "dist\src\extension\plugins\builtin" >nul
    )
)

:: 写入 web build metadata
node scripts/write-web-build-metadata.mjs dist

echo ✓ 后端构建完成

echo.
echo [4/4] 构建前端...

cd /d "%PROJECT_ROOT%\ui"
call npx vite build

if errorlevel 1 (
    echo 错误: 前端构建失败
    pause
    exit /b 1
)

cd /d "%PROJECT_ROOT%"

echo.
echo ═══════════════════════════════════════════════════════════════════
echo   构建完成！
echo ═══════════════════════════════════════════════════════════════════
echo.
echo 接下来:
echo   1. 打包: deploy\package.bat
echo   2. 配置: deploy\setup-lingma.bat
echo   3. 启动: start-windows.bat (打包后) 或 node ui/server/webRuntimeSupervisor.js start-built
echo.
pause
