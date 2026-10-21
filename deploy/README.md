# PilotDeck + Lingma 部署包

这是为内网环境定制的 PilotDeck 部署包，已集成 Lingma 模型支持。

## 系统要求

- **Node.js**: >= 22.13.0
- **操作系统**: Linux / macOS
- **网络**: 可访问 `http://25.0.97.48`（Lingma 内网服务）

## 快速开始

### 1. 解压部署包

```bash
tar -xzf pilotdeck-lingma-deploy.tar.gz
cd pilotdeck-lingma-deploy
```

### 2. 首次配置

```bash
./deploy/setup-lingma.sh
```

脚本会引导您：
1. 访问 Lingma 登录页面
2. 获取 Personal Access Token
3. 生成配置文件

### 3. 启动服务

```bash
./deploy/start.sh
```

服务启动后：
- **Web UI**: http://localhost:3001
- **Gateway**: ws://localhost:18789

## 目录结构

```
pilotdeck-lingma-deploy/
├── deploy/                    # 部署脚本
│   ├── setup-lingma.sh       # 配置脚本
│   ├── start.sh              # 启动脚本
│   └── lingma-config.yaml    # 配置模板
├── dist/                      # 后端构建产物
├── ui/
│   └── dist/                 # 前端构建产物
├── node_modules/             # 依赖包
├── package.json
└── README.md
```

## 配置说明

配置文件位置: `~/.pilotdeck/pilotdeck.yaml`

主要配置项：

```yaml
schemaVersion: 1
agent:
  model: lingma/lingma-pro  # 默认模型

model:
  providers:
    lingma:
      protocol: openai
      url: http://25.0.97.48/algo/api/v1
      apiKey: YOUR_TOKEN_HERE  # Lingma Token
      models:
        lingma-pro:
          capabilities:
            maxOutputTokens: 8192
            maxContextTokens: 24000

router:
  scenarios:
    default: lingma/lingma-pro
```

## 常用命令

### 查看状态

```bash
# 查看配置文件
cat ~/.pilotdeck/pilotdeck.yaml

# 查看日志
tail -f ~/.pilotdeck/logs/server.log
```

### 更新 Token

```bash
# 编辑配置文件
nano ~/.pilotdeck/pilotdeck.yaml

# 或直接重新运行配置脚本
./deploy/setup-lingma.sh
```

### 停止服务

```bash
# 按 Ctrl+C 停止前台服务
# 或
pkill -f "webRuntimeSupervisor"
```

### 重启服务

```bash
./deploy/start.sh
```

## 故障排查

### 1. 无法访问 Lingma 服务

```bash
# 测试网络连通性
curl http://25.0.97.48/algo/api/v1/health
```

### 2. Token 无效

- 确认 Token 已正确复制到配置文件
- 确认 Token 未过期
- 重新运行 `./deploy/setup-lingma.sh`

### 3. 端口被占用

编辑启动脚本，修改端口：

```bash
export SERVER_PORT=3002
export PILOTDECK_GATEWAY_PORT=18790
```

### 4. Node.js 版本过低

```bash
# 查看当前版本
node -v

# 升级到 22+
# 使用 nvm:
nvm install 22
nvm use 22
```

## 高级配置

### 自定义模型参数

编辑 `~/.pilotdeck/pilotdeck.yaml`：

```yaml
model:
  providers:
    lingma:
      # ...
      models:
        lingma-pro:
          capabilities:
            maxOutputTokens: 16384  # 增加输出长度
            maxContextTokens: 32000 # 增加上下文长度
```

### 启用多个模型

```yaml
agent:
  model: lingma/lingma-pro  # 复杂任务
  lightModel: lingma/lingma-lite  # 简单任务

router:
  tokenSaver:
    tiers:
      simple:
        model: lingma/lingma-lite
      complex:
        model: lingma/lingma-pro
```

### 后台运行

```bash
# 使用 nohup
nohup ./deploy/start.sh > pilotdeck.log 2>&1 &

# 使用 screen
screen -S pilotdeck
./deploy/start.sh
# 按 Ctrl+A, D 分离会话

# 使用 systemd (推荐)
# 创建服务文件: /etc/systemd/system/pilotdeck.service
```

## 更新日志

### v1.0.0 (2026-01-21)

- ✅ 集成 Lingma 内网模型支持
- ✅ 添加 Lingma 认证模块
- ✅ 提供一键部署脚本
- ✅ 优化配置流程
- ✅ 完整构建打包

## 技术支持

- 项目仓库: https://github.com/OpenBMB/PilotDeck
- 问题反馈: 提交 Issue 或联系开发团队

## 许可证

AGPL-3.0
