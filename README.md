# LLM 快捷指令

轻量级 iOS App，为 iOS 快捷指令提供第三方原子能力扩展。首个能力是：调用云端 LLM 大模型（支持自定义 API Key 和 Base URL）。

## 功能特性

- **自定义 LLM 配置**：支持配置任意 OpenAI 兼容格式的 LLM 服务端点
- **快捷指令集成**：通过 App Intents 直接在快捷指令中调用大模型
- **多配置管理**：可同时保存多个 LLM 配置，快捷指令中按需选择
- **测试连接**：在 App 内直接测试配置是否可用
- **轻量化**：纯原生 Swift 实现，无第三方依赖

## 项目结构

```
LLMCapability/
├── LLMCapabilityApp.swift          # App 入口
├── ContentView.swift               # 主界面（配置管理）
├── Info.plist                      # 项目配置
├── Capabilities/
│   ├── AtomicCapability.swift      # 原子能力协议与注册表
│   └── LLM/
│       ├── LLMCapability.swift     # LLM 能力实现
│       ├── CallLLMIntent.swift     # 快捷指令 Intent
│       ├── LLMConfig.swift         # 配置数据模型
│       └── LLMConfigView.swift     # 配置编辑界面
├── Services/
│   └── HTTPClient.swift            # 轻量级 HTTP 客户端
└── Models/
    └── LLMRequest.swift            # OpenAI 兼容请求/响应模型
```

## 快速开始

### 环境要求

- macOS 14+
- Xcode 15+
- iOS 16+ 设备或模拟器

### 方法一：使用 xcodegen（推荐）

1. 安装 xcodegen：
   ```bash
   brew install xcodegen
   ```

2. 在项目根目录生成 Xcode 工程：
   ```bash
   cd /Users/yinbo/AI_Project/apple_app
   xcodegen generate
   ```

3. 打开生成的 `LLMCapability.xcodeproj`，选择目标设备后运行（⌘+R）。

### 方法二：手动创建 Xcode 工程

1. 打开 Xcode，选择 **File > New > Project**
2. 选择 **iOS App**，点击 Next
3. 填写信息：
   - **Name**: LLMCapability
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Minimum Deployments**: iOS 16.0
4. 将 `LLMCapability/` 目录下的所有 Swift 文件拖入 Xcode 项目中
5. 在 **Signing & Capabilities** 中配置你的 Team 和 Bundle Identifier
6. 运行项目

## 使用说明

### 在 App 内配置 LLM

1. 打开 App，点击右上角 **+**
2. 填写配置信息：
   - **配置名称**：任意便于识别的名称
   - **Base URL**：LLM API 的完整请求地址（如 `https://api.openai.com/v1/chat/completions`）
   - **API Key**：你的 API 密钥
   - **模型名称**：如 `gpt-3.5-turbo`、`gpt-4` 等
3. 点击 **测试连接** 验证配置可用
4. 点击 **保存**

### 在快捷指令中使用

1. 打开 iOS **快捷指令** App
2. 创建或编辑一个快捷指令
3. 在操作搜索框中输入 App 名称或「LLM」
4. 选择 **调用 LLM** 操作
5. 填写提示词内容，可选择指定配置名称
6. 保存并运行快捷指令

## 扩展更多能力

本项目采用**能力注册表**架构，新增原子能力非常简单：

1. 在 `Capabilities/` 下新建目录（如 `HTTP/`）
2. 创建配置模型（遵循 `Codable`）
3. 实现 `AtomicCapability` 协议
4. 创建 `AppIntent` 暴露给快捷指令
5. 在 `CapabilityRegistry` 中注册配置管理逻辑

## 常见问题

**Q: 支持哪些 LLM 服务商？**
A: 任何提供 OpenAI 兼容 API 的服务均可使用，包括 OpenAI、Azure OpenAI、本地部署的 Ollama/vLLM、以及各类国内大模型服务商。

**Q: API Key 是否安全？**
A: API Key 仅通过 `UserDefaults` 保存在设备本地，不会上传到任何服务器。

**Q: 为什么快捷指令中找不到操作？**
A: 首次安装后可能需要等待 1-2 分钟，或尝试重新启动设备。确保 App 至少运行过一次。
