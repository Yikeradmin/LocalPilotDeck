#!/bin/bash

# PilotDeck + Lingma 一键部署脚本
# 用于在内网环境快速部署支持 Lingma 模型的 PilotDeck 服务

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║         PilotDeck + Lingma 一键部署脚本                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查必要文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOTDECK_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${YELLOW}[1/5]${NC} 检查环境..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}错误: 未找到 Node.js${NC}"
    echo "请先安装 Node.js 22+: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    echo -e "${RED}错误: Node.js 版本过低 (当前: v$NODE_VERSION, 需要: >=22)${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Node.js $(node -v)"

echo -e "${YELLOW}[2/5]${NC} 检查构建产物..."
if [ ! -d "$PILOTDECK_DIR/dist" ]; then
    echo -e "${RED}错误: 未找到构建产物 (dist/)${NC}"
    echo "请先运行: npm run build"
    exit 1
fi

if [ ! -d "$PILOTDECK_DIR/ui/dist" ]; then
    echo -e "${RED}错误: 未找到 UI 构建产物 (ui/dist/)${NC}"
    echo "请先运行: cd ui && npm run build"
    exit 1
fi

echo -e "${GREEN}✓${NC} 构建产物完整"

echo -e "${YELLOW}[3/5]${NC} 配置 Lingma 认证..."
PILOT_HOME="${PILOT_HOME:-$HOME/.pilotdeck}"
mkdir -p "$PILOT_HOME"

CONFIG_FILE="$PILOT_HOME/pilotdeck.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "正在生成配置文件..."
    
    # 提示用户输入 Token
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                     Lingma 登录指引                              ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                  ║"
    echo "║  1. 在浏览器中打开登录页面:                                      ║"
    echo "║     http://25.0.97.48/users/login                               ║"
    echo "║                                                                  ║"
    echo "║  2. 使用您的账号登录                                             ║"
    echo "║                                                                  ║"
    echo "║  3. 登录后访问 Token 页面:                                       ║"
    echo "║     http://25.0.97.48/users/settings/personalAccessToken        ║"
    echo "║                                                                  ║"
    echo "║  4. 复制 Personal Access Token                                   ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    read -p "请输入您的 Lingma Token: " LINGMA_TOKEN
    
    if [ -z "$LINGMA_TOKEN" ]; then
        echo -e "${RED}错误: Token 不能为空${NC}"
        exit 1
    fi
    
    # 生成配置文件
    cat > "$CONFIG_FILE" << YAML
schemaVersion: 1
agent:
  model: lingma/lingma-pro
model:
  providers:
    lingma:
      protocol: openai
      url: http://25.0.97.48/algo/api/v1
      apiKey: $LINGMA_TOKEN
      models:
        lingma-pro:
          capabilities:
            maxOutputTokens: 8192
            maxContextTokens: 24000
cron:
  enabled: true
router:
  scenarios:
    default: lingma/lingma-pro
  fallback:
    default:
      - lingma/lingma-pro
  zeroUsageRetry:
    enabled: true
    maxAttempts: 2
  tokenSaver:
    enabled: true
    judge: lingma/lingma-pro
    defaultTier: medium
    judgeTimeoutMs: 15000
    tiers:
      simple:
        model: lingma/lingma-pro
        description: "Simple greetings, confirmations, single-step Q&A"
      medium:
        model: lingma/lingma-pro
        description: "Single tool call, short text generation, code generation"
      complex:
        model: lingma/lingma-pro
        description: "Multi-file operations, data analysis, multi-step workflows"
      reasoning:
        model: lingma/lingma-pro
        description: "Deep analysis, structured reports"
YAML
    
    echo -e "${GREEN}✓${NC} 配置文件已生成: $CONFIG_FILE"
else
    echo -e "${GREEN}✓${NC} 配置文件已存在: $CONFIG_FILE"
fi

echo -e "${YELLOW}[4/5]${NC} 启动 PilotDeck 服务..."
echo ""
echo "服务将监听以下端口:"
echo "  - Web UI: http://localhost:3001"
echo "  - Gateway: ws://localhost:18789"
echo ""
echo "按 Ctrl+C 停止服务"
echo ""

cd "$PILOTDECK_DIR"

# 设置环境变量
export NODE_ENV=production
export PILOT_HOME="$PILOT_HOME"
export SERVER_PORT=3001
export PILOTDECK_GATEWAY_PORT=18789

# 启动服务
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  PilotDeck 服务启动中...${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo ""

# 使用 node 直接运行
exec node ui/server/webRuntimeSupervisor.js start-built
