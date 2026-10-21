# PilotDeck 部署包安装说明

## 文件合并

您收到的是分卷压缩包，需要先合并：

```bash
# 1. 将所有分卷文件放到同一目录
ls -lh pilotdeck-part-*

# 2. 合并分卷
cat pilotdeck-part-* > pilotdeck-full.tar

# 3. 解压
tar -xf pilotdeck-full.tar

# 4. 进入目录
cd pilotdeck-lingma-deploy
```

## 首次配置

```bash
# 运行配置脚本（会引导您获取并配置 Lingma Token）
./deploy/setup-lingma.sh
```

配置脚本会提示您：
1. 访问 Lingma 登录页面获取 Token
2. 输入 Token 到配置文件
3. 自动生成 `~/.pilotdeck/pilotdeck.yaml`

## 启动服务

```bash
# 启动 PilotDeck 服务
./deploy/start.sh
```

服务启动后：
- **Web UI**: http://localhost:3001
- **Gateway**: ws://localhost:18789

## 系统要求

- Node.js >= 22.13.0
- Linux / macOS
- 可访问 http://25.0.97.48（Lingma 服务）

## 获取 Lingma Token

1. 访问：http://25.0.97.48/users/login
2. 使用内网账号登录
3. 访问：http://25.0.97.48/users/settings/personalAccessToken
4. 复制 Personal Access Token

## 常见问题

### 端口被占用

编辑 `deploy/start.sh`，修改端口：
```bash
export SERVER_PORT=3002
export PILOTDECK_GATEWAY_PORT=18790
```

### 查看日志

```bash
# 服务日志
tail -f ~/.pilotdeck/logs/server.log

# Gateway 日志
tail -f ~/.pilotdeck/logs/gateway.log
```

### 停止服务

```bash
# 前台模式：按 Ctrl+C
# 后台模式：
pkill -f "webRuntimeSupervisor"
```

### 重启服务

```bash
./deploy/start.sh
```

## 完整部署包内容

```
pilotdeck-lingma-deploy/
├── deploy/                  # 部署脚本
│   ├── setup-lingma.sh     # 配置脚本
│   ├── start.sh            # 启动脚本
│   └── README.md           # 部署文档
├── dist/                   # 后端构建产物
├── ui/
│   └── dist/              # 前端构建产物
├── node_modules/          # 依赖包（已安装）
├── resources/             # 资源文件
├── skills/                # 技能模块
├── scripts/               # 工具脚本
├── package.json
├── tsconfig.json
└── README.md
```

## 技术架构

- **后端**: Node.js + TypeScript
- **前端**: React + Vite
- **协议**: OpenAI Compatible API
- **模型**: Lingma (http://25.0.97.48/algo/api/v1)
- **认证**: Bearer Token

## 更新日志

### v1.0.0 (2026-01-21)

- ✅ 集成 Lingma 内网模型
- ✅ 完整构建打包
- ✅ 自动化部署脚本
- ✅ 中文文档支持

## 技术支持

遇到问题请查看：
- `deploy/README.md` - 详细部署文档
- `DEPLOY_README.md` - 项目说明
- `QUICK_DEPLOY.md` - 快速部署指南

## 许可证

AGPL-3.0
