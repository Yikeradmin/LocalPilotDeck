# PilotDeck + Lingma 定制版

这是为内网环境定制的 PilotDeck 部署版本，已完全集成 Lingma 模型支持。

## 新增特性

### 1. Lingma 模型集成

- ✅ 添加 Lingma 作为内置模型提供商
- ✅ 支持 Bearer Token 认证
- ✅ 自动 Token 管理和持久化
- ✅ 完整的登录引导流程

### 2. 认证管理

- ✅ 本地 Token 安全存储（`~/.pilotdeck/lingma-token.json`）
- ✅ 浏览器自动打开登录页面
- ✅ Token 有效性检查
- ✅ 一键登出功能

### 3. 部署优化

- ✅ 一键部署脚本
- ✅ 交互式配置向导
- ✅ 完整的错误处理
- ✅ 生产环境优化

## 快速开始

### 方式一：使用部署包

```bash
# 解压
tar -xzf pilotdeck-lingma-deploy.tar.gz
cd pilotdeck-lingma-deploy

# 配置
./deploy/setup-lingma.sh

# 启动
./deploy/start.sh
```

### 方式二：从源码构建

```bash
# 安装依赖
pnpm install

# 构建后端
npm run build

# 构建前端
cd ui && npm run build && cd ..

# 配置
./deploy/setup-lingma.sh

# 启动
./deploy/start.sh
```

## 访问地址

启动成功后：
- **Web UI**: http://localhost:3001
- **Gateway**: ws://localhost:18789

## 配置说明

### 环境变量

```bash
# 服务端口
export SERVER_PORT=3001

# Gateway 端口
export PILOTDECK_GATEWAY_PORT=18789

# 配置目录
export PILOT_HOME=~/.pilotdeck
```

### 配置文件

位置: `~/.pilotdeck/pilotdeck.yaml`

```yaml
schemaVersion: 1
agent:
  model: lingma/lingma-pro

model:
  providers:
    lingma:
      protocol: openai
      url: http://25.0.97.48/algo/api/v1
      apiKey: YOUR_TOKEN
      models:
        lingma-pro:
          capabilities:
            maxOutputTokens: 8192
            maxContextTokens: 24000

router:
  scenarios:
    default: lingma/lingma-pro
  tokenSaver:
    enabled: true
    judge: lingma/lingma-pro
```

## Lingma 认证流程

1. **登录**
   - 访问: http://25.0.97.48/users/login
   - 使用内网账号登录

2. **获取 Token**
   - 访问: http://25.0.97.48/users/settings/personalAccessToken
   - 复制 Personal Access Token

3. **配置**
   - 运行配置脚本或手动编辑配置文件
   - 将 Token 填入 `apiKey` 字段

## 模型能力

### lingma-pro

- **协议**: OpenAI Compatible
- **上下文窗口**: 24,000 tokens
- **最大输出**: 8,192 tokens
- **支持特性**:
  - ✅ 工具调用
  - ✅ 流式响应
  - ✅ 系统提示
  - ❌ 并行工具调用
  - ❌ 思考过程
  - ❌ JSON Schema

## 智能路由

PilotDeck 内置智能路由系统，自动根据任务难度选择模型：

- **Simple**: 简单问候、确认、单步问答
- **Medium**: 单次工具调用、短文本生成、代码生成
- **Complex**: 多文件操作、数据分析、多步骤工作流
- **Reasoning**: 深度分析、结构化报告

## 故障排查

### 连接问题

```bash
# 检查 Lingma 服务
curl http://25.0.97.48/algo/api/v1/health

# 检查端口占用
netstat -tlnp | grep 3001
netstat -tlnp | grep 18789

# 查看日志
tail -f ~/.pilotdeck/logs/server.log
```

### 认证问题

```bash
# 检查 Token 文件
cat ~/.pilotdeck/lingma-token.json

# 重新配置
./deploy/setup-lingma.sh
```

### 服务问题

```bash
# 检查 Node.js 版本
node -v  # 需要 >= 22

# 重启服务
./deploy/start.sh

# 清理缓存
rm -rf ~/.pilotdeck/cache
```

## 开发说明

### 代码结构

```
src/model/providers/lingma/
├── auth.ts          # 认证管理
└── index.ts         # Provider 导出

src/model/catalog/
└── providers.ts     # 模型目录（已添加 lingma）

deploy/
├── setup-lingma.sh  # 配置脚本
├── start.sh         # 启动脚本
└── lingma-config.yaml  # 配置模板
```

### 构建

```bash
# 开发模式
npm run dev

# 生产构建
npm run build
cd ui && npm run build
```

### 测试

```bash
# 运行测试
npm test

# 类型检查
npx tsc --noEmit
```

## 更新日志

### v1.0.0 (2026-01-21)

**首次发布**

- ✅ 集成 Lingma 内网模型
- ✅ 实现认证管理模块
- ✅ 提供一键部署脚本
- ✅ 完整构建打包
- ✅ 详细使用文档

## 许可证

AGPL-3.0

## 致谢

- [PilotDeck](https://github.com/OpenBMB/PilotDeck) - 原始项目
- THUNLP + OpenBMB - 开发团队
- Lingma - 内网模型支持
