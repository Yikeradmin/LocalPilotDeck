#!/bin/bash

# PilotDeck + Lingma 自动化安装脚本
# 此脚本会在用户机器上自动构建和部署 PilotDeck

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║     ${GREEN}PilotDeck + Lingma${BLUE} 自动化部署                                   ║${NC}"
echo -e "${BLUE}║     ${YELLOW}内网模型定制版${BLUE}                                                 ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 检查系统要求
echo -e "${YELLOW}[1/7]${NC} 检查系统要求..."

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}错误: 未找到 Node.js${NC}"
    echo "请先安装 Node.js 22+: https://nodejs.org/"
    echo ""
    echo "或使用 nvm 安装:"
    echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo "  nvm install 22"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    echo -e "${RED}错误: Node.js 版本过低 (当前: v$NODE_VERSION, 需要: >=22)${NC}"
    echo "请升级 Node.js:"
    echo "  nvm install 22"
    echo "  nvm use 22"
    exit 1
fi

echo -e "${GREEN}✓${NC} Node.js $(node -v)"

# 检查 pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}[2/7]${NC} 安装 pnpm..."
    npm install -g pnpm@10.32.1
else
    echo -e "${GREEN}✓${NC} pnpm 已安装 ($(pnpm -v))"
fi

# 安装依赖
echo -e "${YELLOW}[3/7]${NC} 安装项目依赖..."
cd "$PROJECT_ROOT"
pnpm install

# 构建后端
echo -e "${YELLOW}[4/7]${NC} 构建后端..."
npm run build

# 构建前端
echo -e "${YELLOW}[5/7]${NC} 构建前端..."
cd ui
npm run build
cd ..

# 配置 Lingma
echo -e "${YELLOW}[6/7]${NC} 配置 Lingma..."
echo ""
chmod +x "$SCRIPT_DIR/setup-lingma.sh"
"$SCRIPT_DIR/setup-lingma.sh"

# 启动服务
echo -e "${YELLOW}[7/7]${NC} 启动服务..."
echo ""
chmod +x "$SCRIPT_DIR/start.sh"
"$SCRIPT_DIR/start.sh"
