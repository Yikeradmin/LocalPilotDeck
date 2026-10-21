# PilotDeck + Lingma 快速部署指南

## 方案一：完整自动化部署（推荐）

### 在目标服务器上执行以下命令：

```bash
# 1. 下载 PilotDeck 源码
git clone https://github.com/OpenBMB/PilotDeck.git
cd PilotDeck

# 2. 应用 Lingma 集成补丁
# 从您的部署包中提取 lingma-integration-patch.tar.gz
tar -xzf lingma-integration-patch.tar.gz
cp -r lingma-patch/* .

# 3. 一键构建和部署
chmod +x deploy/auto-deploy.sh
./deploy/auto-deploy.sh
```

脚本会自动：
- 安装 Node.js 22+（如果未安装）
- 安装 pnpm
- 安装依赖
- 构建项目
- 配置 Lingma
- 启动服务

## 方案二：手动构建部署

### 前置要求

- Node.js >= 22.13.0
- pnpm >= 10.32.1
- Git

### 构建步骤

```bash
# 1. 克隆仓库
git clone https://github.com/OpenBMB/PilotDeck.git
cd PilotDeck

# 2. 应用 Lingma 补丁
tar -xzf lingma-integration-patch.tar.gz
cp -r lingma-patch/src/model/providers/lingma src/model/providers/
cp -r lingma-patch/deploy deploy
cp lingma-patch/src/model/catalog/providers.ts src/model/catalog/providers.ts

# 3. 安装依赖
pnpm install

# 4. 构建后端
npm run build

# 5. 构建前端
cd ui && npm run build && cd ..

# 6. 配置 Lingma
./deploy/setup-lingma.sh

# 7. 启动服务
./deploy/start.sh
```

## 方案三：Docker 部署

```bash
# 1. 克隆并应用补丁
git clone https://github.com/OpenBMB/PilotDeck.git
cd PilotDeck
tar -xzf lingma-integration-patch.tar.gz
cp -r lingma-patch/* .

# 2. 构建镜像
docker build -t pilotdeck-lingma .

# 3. 运行容器
docker run -d \
  --name pilotdeck \
  -p 3001:3001 \
  -e LINGMA_API_KEY=your_token_here \
  -v pilotdeck-data:/root/.pilotdeck \
  pilotdeck-lingma
```

## 访问地址

部署成功后：
- **Web UI**: http://localhost:3001
- **Gateway**: ws://localhost:18789

## Lingma Token 获取

1. 访问: http://25.0.97.48/users/login
2. 使用内网账号登录
3. 访问: http://25.0.97.48/users/settings/personalAccessToken
4. 复制 Personal Access Token

## 补丁包内容

```
lingma-integration-patch.tar.gz
├── lingma-patch/
│   ├── src/
│   │   └── model/
│   │       ├── providers/
│   │       │   └── lingma/
│   │       │       └── auth.ts          # Lingma 认证模块
│   │       └── catalog/
│   │           └── providers.ts          # 模型目录（已添加 lingma）
│   ├── deploy/
│   │   ├── auto-deploy.sh              # 一键部署脚本
│   │   ├── setup-lingma.sh             # 配置脚本
│   │   ├── start.sh                    # 启动脚本
│   │   └── README.md                   # 部署文档
│   ├── DEPLOY_README.md                # 项目说明
│   └── Dockerfile.lingma               # Docker 配置（可选）
└── INSTALL.sh                          # 快速安装脚本
```

## 故障排查

### 1. Node.js 版本问题

```bash
# 检查版本
node -v

# 使用 nvm 升级
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 22
nvm use 22
```

### 2. 网络问题

```bash
# 如果无法访问 GitHub，可以使用镜像
git clone https://gitee.com/mirrors/PilotDeck.git

# 或使用 VPN/代理
export https_proxy=http://your-proxy:port
```

### 3. 构建失败

```bash
# 清理缓存
pnpm store prune
rm -rf node_modules

# 重新安装
pnpm install
```

### 4. 端口冲突

编辑 `deploy/start.sh`，修改端口：

```bash
export SERVER_PORT=3002
export PILOTDECK_GATEWAY_PORT=18790
```

## 系统要求

- **操作系统**: Linux (Ubuntu 20.04+, CentOS 8+) / macOS
- **内存**: >= 2GB RAM
- **磁盘**: >= 2GB 可用空间
- **网络**: 可访问 `http://25.0.97.48`（Lingma 服务）

## 性能优化

### 后台运行

```bash
# 使用 systemd（推荐）
sudo cp deploy/pilotdeck.service /etc/systemd/system/
sudo systemctl enable pilotdeck
sudo systemctl start pilotdeck

# 使用 screen
screen -S pilotdeck
./deploy/start.sh
# Ctrl+A, D 分离会话

# 使用 nohup
nohup ./deploy/start.sh > pilotdeck.log 2>&1 &
```

### 负载均衡

多个实例可以共享同一个 Lingma Token，使用 nginx 做负载均衡：

```nginx
upstream pilotdeck {
    server localhost:3001;
    server localhost:3002;
}

server {
    listen 80;
    server_name pilotdeck.example.com;
    
    location / {
        proxy_pass http://pilotdeck;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 更新日志

### v1.0.0 (2026-01-21)

- ✅ 添加 Lingma 模型支持
- ✅ 实现 Bearer Token 认证
- ✅ 提供自动化部署脚本
- ✅ 完整的中文文档
- ✅ 优化内网部署体验

## 技术支持

遇到问题？
1. 查看详细文档: `deploy/README.md`
2. 检查日志: `~/.pilotdeck/logs/`
3. 提交 Issue: https://github.com/OpenBMB/PilotDeck/issues

## 许可证

AGPL-3.0
