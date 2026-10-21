#!/bin/bash

# PilotDeck + Lingma 打包脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  PilotDeck + Lingma 部署包打包工具${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo ""

# 检查构建产物
echo -e "${YELLOW}[1/4]${NC} 检查构建产物..."

if [ ! -d "$PROJECT_ROOT/dist" ]; then
    echo -e "${RED}错误: 后端构建产物不存在${NC}"
    echo "请先运行: npm run build"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/ui/dist" ]; then
    echo -e "${RED}错误: 前端构建产物不存在${NC}"
    echo "请先运行: cd ui && npm run build"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/node_modules" ]; then
    echo -e "${RED}错误: node_modules 不存在${NC}"
    echo "请先运行: pnpm install"
    exit 1
fi

echo -e "${GREEN}✓${NC} 构建产物完整"

# 准备打包目录
echo -e "${YELLOW}[2/4]${NC} 准备打包目录..."

PACKAGE_DIR="$PROJECT_ROOT/pilotdeck-lingma-deploy"
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# 复制必要文件
echo -e "${YELLOW}[3/4]${NC} 复制文件..."

# 核心文件
cp -r "$PROJECT_ROOT/dist" "$PACKAGE_DIR/"
cp -r "$PROJECT_ROOT/ui" "$PACKAGE_DIR/"
cp -r "$PROJECT_ROOT/node_modules" "$PACKAGE_DIR/"
cp -r "$PROJECT_ROOT/skills" "$PACKAGE_DIR/" 2>/dev/null || true
cp -r "$PROJECT_ROOT/resources" "$PACKAGE_DIR/" 2>/dev/null || true
cp -r "$PROJECT_ROOT/scripts" "$PACKAGE_DIR/"

# 配置文件
cp "$PROJECT_ROOT/package.json" "$PACKAGE_DIR/"
cp "$PROJECT_ROOT/pnpm-lock.yaml" "$PACKAGE_DIR/"
cp "$PROJECT_ROOT/pnpm-workspace.yaml" "$PACKAGE_DIR/" 2>/dev/null || true
cp "$PROJECT_ROOT/tsconfig.json" "$PACKAGE_DIR/"

# 部署脚本
cp -r "$PROJECT_ROOT/deploy" "$PACKAGE_DIR/"

# 文档
cp "$PROJECT_ROOT/DEPLOY_README.md" "$PACKAGE_DIR/README.md"
cp "$PROJECT_ROOT/deploy/README.md" "$PACKAGE_DIR/deploy/README.md"

# 清理不必要的文件
echo -e "${YELLOW}[4/4]${NC} 清理临时文件..."

find "$PACKAGE_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "$PACKAGE_DIR" -type f -name "*.pyc" -delete 2>/dev/null || true
find "$PACKAGE_DIR" -type d -name ".git" -exec rm -rf {} + 2>/dev/null || true
find "$PACKAGE_DIR" -type d -name "test" -exec rm -rf {} + 2>/dev/null || true
find "$PACKAGE_DIR" -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true
find "$PACKAGE_DIR" -type d -name ".cache" -exec rm -rf {} + 2>/dev/null || true
find "$PACKAGE_DIR" -type f -name "*.log" -delete 2>/dev/null || true

# 创建压缩包
echo ""
echo -e "${GREEN}正在创建压缩包...${NC}"

cd "$PROJECT_ROOT"
tar -czf pilotdeck-lingma-deploy.tar.gz pilotdeck-lingma-deploy

# 显示结果
PACKAGE_SIZE=$(du -h pilotdeck-lingma-deploy.tar.gz | cut -f1)

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  打包完成！${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "部署包: ${YELLOW}pilotdeck-lingma-deploy.tar.gz${NC}"
echo -e "大  小: ${YELLOW}$PACKAGE_SIZE${NC}"
echo ""
echo -e "部署步骤:"
echo -e "  1. 解压: ${YELLOW}tar -xzf pilotdeck-lingma-deploy.tar.gz${NC}"
echo -e "  2. 配置: ${YELLOW}cd pilotdeck-lingma-deploy && ./deploy/setup-lingma.sh${NC}"
echo -e "  3. 启动: ${YELLOW}./deploy/start.sh${NC}"
echo ""
echo -e "访问地址:"
echo -e "  Web UI:  ${GREEN}http://localhost:3001${NC}"
echo -e "  Gateway: ${GREEN}ws://localhost:18789${NC}"
echo ""
