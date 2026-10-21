#!/bin/bash

# PilotDeck + Lingma 快速启动脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILOTDECK_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║     ${GREEN}PilotDeck + Lingma${BLUE}                                             ║${NC}"
echo -e "${BLUE}║     ${YELLOW}智能体操作系统 - 内网模型版${BLUE}                                    ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查配置文件
PILOT_HOME="${PILOT_HOME:-$HOME/.pilotdeck}"
CONFIG_FILE="$PILOT_HOME/pilotdeck.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}首次运行，需要配置 Lingma 认证信息${NC}"
    echo ""
    "$SCRIPT_DIR/setup-lingma.sh"
    exit $?
fi

# 显示配置信息
echo -e "${GREEN}✓${NC} 配置文件: $CONFIG_FILE"
echo ""

# 检查构建产物
if [ ! -d "$PILOTDECK_DIR/dist" ] || [ ! -d "$PILOTDECK_DIR/ui/dist" ]; then
    echo -e "${RED}错误: 构建产物不完整${NC}"
    echo "请重新构建项目:"
    echo "  npm install && npm run build"
    echo "  cd ui && npm run build"
    exit 1
fi

# 设置环境变量
export NODE_ENV=production
export PILOT_HOME="$PILOT_HOME"
export SERVER_PORT=${SERVER_PORT:-3001}
export PILOTDECK_GATEWAY_PORT=${PILOTDECK_GATEWAY_PORT:-18789}

echo "══════════════════════════════════════════════════════════════════"
echo ""
echo -e "服务地址:"
echo -e "  ${GREEN}Web UI:${NC}     http://localhost:$SERVER_PORT"
echo -e "  ${GREEN}Gateway:${NC}    ws://localhost:$PILOTDECK_GATEWAY_PORT"
echo ""
echo -e "使用 ${YELLOW}Ctrl+C${NC} 停止服务"
echo ""
echo "══════════════════════════════════════════════════════════════════"
echo ""

cd "$PILOTDECK_DIR"

# 启动服务
exec node ui/server/webRuntimeSupervisor.js start-built
