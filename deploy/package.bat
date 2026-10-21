@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ═══════════════════════════════════════════════════════════════════
echo   PilotDeck + Lingma 部署包打包工具 (Windows)
echo ═══════════════════════════════════════════════════════════════════
echo.

:: 获取项目根目录
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

:: 检查构建产物
echo [1/4] 检查构建产物...

if not exist "%PROJECT_ROOT%\dist" (
    echo 错误: 后端构建产物不存在
    echo 请先运行: npm run build
    pause
    exit /b 1
)

if not exist "%PROJECT_ROOT%\ui\dist" (
    echo 错误: 前端构建产物不存在
    echo 请先运行: cd ui ^&^& npm run build
    pause
    exit /b 1
)

if not exist "%PROJECT_ROOT%\node_modules" (
    echo 错误: node_modules 不存在
    echo 请先运行: pnpm install
    pause
    exit /b 1
)

echo ✓ 构建产物完整

:: 准备打包目录
echo [2/4] 准备打包目录...

set "PACKAGE_DIR=%PROJECT_ROOT%\pilotdeck-lingma-deploy"

:: 删除旧目录
if exist "%PACKAGE_DIR%" (
    rmdir /s /q "%PACKAGE_DIR%"
)
mkdir "%PACKAGE_DIR%"

:: 复制核心文件
echo [3/4] 复制文件...

echo   复制 dist...
xcopy /e /i /q "%PROJECT_ROOT%\dist" "%PACKAGE_DIR%\dist" >nul

echo   复制 ui...
xcopy /e /i /q "%PROJECT_ROOT%\ui" "%PACKAGE_DIR%\ui" >nul

echo   复制 node_modules...
xcopy /e /i /q "%PROJECT_ROOT%\node_modules" "%PACKAGE_DIR%\node_modules" >nul

if exist "%PROJECT_ROOT%\skills" (
    echo   复制 skills...
    xcopy /e /i /q "%PROJECT_ROOT%\skills" "%PACKAGE_DIR%\skills" >nul
)

if exist "%PROJECT_ROOT%\resources" (
    echo   复制 resources...
    xcopy /e /i /q "%PROJECT_ROOT%\resources" "%PACKAGE_DIR%\resources" >nul
)

echo   复制 scripts...
xcopy /e /i /q "%PROJECT_ROOT%\scripts" "%PACKAGE_DIR%\scripts" >nul

echo   复制配置文件...
copy /y "%PROJECT_ROOT%\package.json" "%PACKAGE_DIR%\" >nul
copy /y "%PROJECT_ROOT%\pnpm-lock.yaml" "%PACKAGE_DIR%\" >nul
if exist "%PROJECT_ROOT%\pnpm-workspace.yaml" (
    copy /y "%PROJECT_ROOT%\pnpm-workspace.yaml" "%PACKAGE_DIR%\" >nul
)
copy /y "%PROJECT_ROOT%\tsconfig.json" "%PACKAGE_DIR%\" >nul

echo   复制部署脚本...
xcopy /e /i /q "%PROJECT_ROOT%\deploy" "%PACKAGE_DIR%\deploy" >nul

echo   复制文档...
copy /y "%PROJECT_ROOT%\DEPLOY_README.md" "%PACKAGE_DIR%\README.md" >nul
copy /y "%PROJECT_ROOT%\deploy\README.md" "%PACKAGE_DIR%\deploy\README.md" >nul

:: 创建启动脚本
echo   创建启动脚本...
(
echo @echo off
echo chcp 65001 ^>nul
echo echo.
echo echo ═══════════════════════════════════════════════════════════════════
echo echo   PilotDeck + Lingma 服务启动
echo echo ═══════════════════════════════════════════════════════════════════
echo echo.
echo echo 正在启动服务...
echo echo.
echo echo Web UI:    http://localhost:3001
echo echo Gateway:   ws://localhost:18789
echo echo.
echo echo 按 Ctrl+C 停止服务
echo echo.
echo echo ═══════════════════════════════════════════════════════════════════
echo echo.
echo cd /d "%%~dp0.."
echo set NODE_ENV=production
echo set SERVER_PORT=3001
echo set PILOTDECK_GATEWAY_PORT=18789
echo node ui/server/webRuntimeSupervisor.js start-built
) > "%PACKAGE_DIR%\start-windows.bat"

:: 创建配置脚本
echo   创建配置脚本...
(
echo @echo off
echo chcp 65001 ^>nul
echo echo.
echo echo ═══════════════════════════════════════════════════════════════════
echo echo   PilotDeck + Lingma 配置向导
echo echo ═══════════════════════════════════════════════════════════════════
echo echo.
echo echo 请在浏览器中打开以下链接获取 Token:
echo echo.
echo echo 1. 登录页面: http://25.0.97.48/users/login
echo echo 2. Token页面: http://25.0.97.48/users/settings/personalAccessToken
echo echo.
echo set /p LINGMA_TOKEN=请输入您的 Lingma Token: 
echo if "%%LINGMA_TOKEN%%"=="" ^(
echo     echo 错误: Token 不能为空
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo.
echo echo 正在生成配置文件...
echo.
echo set "CONFIG_DIR=%%USERPROFILE%%\.pilotdeck"
echo if not exist "%%CONFIG_DIR%%" mkdir "%%CONFIG_DIR%%"
echo.
echo ^(
echo echo schemaVersion: 1
echo echo agent:
echo echo   model: lingma/lingma-pro
echo echo model:
echo echo   providers:
echo echo     lingma:
echo echo       protocol: openai
echo echo       url: http://25.0.97.48/algo/api/v1
echo echo       apiKey: %%LINGMA_TOKEN%%
echo echo       models:
echo echo         lingma-pro:
echo echo           capabilities:
echo echo             maxOutputTokens: 8192
echo echo             maxContextTokens: 24000
echo echo cron:
echo echo   enabled: true
echo echo router:
echo echo   scenarios:
echo echo     default: lingma/lingma-pro
echo ^) ^> "%%CONFIG_DIR%%\pilotdeck.yaml"
echo.
echo echo.
echo echo ✓ 配置文件已生成: %%CONFIG_DIR%%\pilotdeck.yaml
echo echo.
echo echo 现在可以运行 start-windows.bat 启动服务
echo echo.
echo pause
) > "%PACKAGE_DIR%\setup-lingma.bat"

:: 清理临时文件
echo [4/4] 清理临时文件...

cd /d "%PACKAGE_DIR%"
for /d /r %%d in (__pycache__) do if exist "%%d" rmdir /s /q "%%d" 2>nul
for /d /r %%d in (.git) do if exist "%%d" rmdir /s /q "%%d" 2>nul
for /d /r %%d in (test) do if exist "%%d" rmdir /s /q "%%d" 2>nul
for /d /r %%d in (tests) do if exist "%%d" rmdir /s /q "%%d" 2>nul
for /d /r %%d in (.cache) do if exist "%%d" rmdir /s /q "%%d" 2>nul
del /s /q *.log 2>nul

cd /d "%PROJECT_ROOT%"

echo.
echo ═══════════════════════════════════════════════════════════════════
echo   打包完成！
echo ═══════════════════════════════════════════════════════════════════
echo.
echo 部署包目录: pilotdeck-lingma-deploy
echo.
echo 部署步骤:
echo   1. 进入目录: cd pilotdeck-lingma-deploy
echo   2. 配置: setup-lingma.bat
echo   3. 启动: start-windows.bat
echo.
echo 访问地址:
echo   Web UI:  http://localhost:3001
echo   Gateway: ws://localhost:18789
echo.
pause
