# PilotDeck + Lingma 完整部署包

## 📦 部署包说明

这是为内网环境定制的 PilotDeck 完整部署包，已集成 Lingma 模型支持。

## ⚠️ 重要说明

由于完整部署包体积较大（约 1.2GB），无法直接通过聊天传输。我们提供以下部署方案：

## 🚀 部署方案

### 方案一：使用轻量部署包（推荐）

轻量部署包包含所有源码和配置，会在您的机器上自动构建。

**文件**: `pilotdeck-lite.tar` (70MB)

**部署步骤**:

```bash
# 1. 解压
tar -xf pilotdeck-lite.tar
cd PilotDeck

# 2. 一键安装（会自动构建并配置）
chmod +x deploy/install.sh
./deploy/install.sh
```

安装脚本会自动：
- 检查 Node.js 版本
- 安装依赖
- 构建项目
- 配置 Lingma
- 启动服务

### 方案二：使用完整部署包

完整部署包包含所有构建产物，无需再次构建。

**文件**: 分卷压缩，共 25 个部分

**部署步骤**:

```bash
# 1. 将所有分卷文件放到同一目录
ls -lh pilotdeck-part-*

# 2. 合并分卷
cat pilotdeck-part-* > pilotdeck-full.tar

# 3. 解压
tar -xf pilotdeck-full.tar

# 4. 配置并启动
cd pilotdeck-lingma-deploy
./deploy/setup-lingma.sh
./deploy/start.sh
```

### 方案三：从 GitHub 克隆（最简单）

如果您能访问 GitHub，这是最简单的方式：

```bash
# 1. 克隆仓库
git clone https://github.com/OpenBMB/PilotDeck.git
cd PilotDeck

# 2. 应用 Lingma 补丁
tar -xzf lingma-integration-patch.tar.gz
cp -r lingma-patch/* .

# 3. 一键安装
chmod +x deploy/install.sh
./deploy/install.sh
```

## 📋 Lingma Token 获取

1. 访问: http://25.0.97.48/users/login
2. 使用内网账号登录
3. 访问: http://25.0.97.48/users/settings/personalAccessToken
4. 复制 Personal Access Token
5. 在配置脚本中输入

## 🌐 访问地址

部署成功后：
- **Web UI**: http://localhost:3001
- **Gateway**: ws://localhost:18789

## 📁 文件清单

### 轻量部署包 (pilotdeck-lite.tar)
```
PilotDeck/
├── src/                      # 后端源码（含 Lingma 集成）
├── ui/                       # 前端源码
├── deploy/                   # 部署脚本
│   ├── install.sh           # 一键安装脚本
│   ├── setup-lingma.sh      # 配置脚本
│   └── start.sh             # 启动脚本
├── skills/                   # 技能模块
├── scripts/                  # 工具脚本
├── resources/                # 资源文件
├── DEPLOY_README.md          # 项目说明
├── QUICK_DEPLOY.md           # 快速部署
└── deploy/INSTALL.md         # 安装指南
```

### Lingma 补丁包 (lingma-integration-patch.tar.gz, 11KB)
```
lingma-patch/
├── src/
│   └── model/
│       ├── providers/
│       │   └── lingma/
│       │       └── auth.ts          # Lingma 认证模块
│       └── catalog/
│           └── providers.ts          # 模型目录（已添加 lingma）
├── deploy/
│   ├── install.sh
│   ├── setup-lingma.sh
│   └── start.sh
├── DEPLOY_README.md
└── QUICK_DEPLOY.md
```

## 🔧 系统要求

- **Node.js**: >= 22.13.0
- **操作系统**: Linux / macOS
- **内存**: >= 2GB RAM
- **磁盘**: >= 3GB 可用空间
- **网络**: 可访问 http://25.0.97.48

## 📖 文档说明

- `deploy/INSTALL.md` - 详细安装指南
- `QUICK_DEPLOY.md` - 快速部署指南
- `DEPLOY_README.md` - 项目完整说明

## 🐛 故障排查

### Node.js 版本问题
```bash
# 安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 安装并使用 Node.js 22
nvm install 22
nvm use 22
```

### 构建失败
```bash
# 清理缓存
pnpm store prune
rm -rf node_modules dist ui/dist

# 重新安装和构建
pnpm install
npm run build
cd ui && npm run build && cd ..
```

### 端口冲突
编辑 `deploy/start.sh`，修改：
```bash
export SERVER_PORT=3002
export PILOTDECK_GATEWAY_PORT=18790
```

## 📞 技术支持

遇到问题？
1. 查看详细文档: `deploy/INSTALL.md`
2. 检查日志: `~/.pilotdeck/logs/`
3. 查看原始项目: https://github.com/OpenBMB/PilotDeck

## ✨ 新增特性

- ✅ 集成 Lingma 内网模型
- ✅ Bearer Token 认证
- ✅ 自动化部署脚本
- ✅ 中文文档支持
- ✅ 一键安装配置

## 📝 更新日志

### v1.0.0 (2026-01-21)
- 首次发布
- 集成 Lingma 模型
- 提供自动化部署
- 完整中文文档

## 📄 许可证

AGPL-3.0
