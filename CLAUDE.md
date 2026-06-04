# CLAUDE.md

本文档为 Claude Code（claude.ai/code）提供本仓库的工作指南。

## 构建与运行

本项目使用 **xcodegen** 从 `project.yml` 生成 `.xcodeproj`。请勿提交生成的 `.xcodeproj`。

```bash
# 生成 Xcode 项目
xcodegen generate

# 命令行构建（需要安装 Xcode）
xcodebuild -project AtomBridge.xcodeproj -scheme AtomBridge -destination 'platform=iOS Simulator,name=iPhone 15' build
```

生成后，用 Xcode 打开 `AtomBridge.xcodeproj`，按 ⌘+R 运行。App 目标平台为 iOS 16.0+。

## 架构

### 能力注册表模式

App 围绕**能力注册表**构建，旨在支持多个原子能力暴露给 iOS 快捷指令。

- `AtomicCapability` 协议（`Capabilities/AtomicCapability.swift`）定义了合约：`capabilityID`、`displayName`、`description`。
- `CapabilityRegistry` 是一个单例 `ObservableObject`，管理所有能力配置。目前管理 `LLMConfig` 和 `HTTPConfig` 实例。
- 每个新增能力应遵循：（1）创建符合 `Codable` 的配置模型，（2）实现 `AtomicCapability`，（3）创建 `AppIntent`，（4）在 `CapabilityRegistry` 中注册配置的增删改查。

### App Intents 集成（iOS 16+）

快捷指令集成使用现代的 **App Intents** 框架，无需额外的 Intents Extension Target，保持 App 轻量。

- `CallLLMIntent`、`CallLLMWithSystemPromptIntent`（`Capabilities/LLM/CallLLMIntent.swift`）以及 `CallHTTPIntent`（`Capabilities/HTTP/CallHTTPIntent.swift`）均符合 `AppIntent`。
- `LLMAppShortcuts` 和 `HTTPAppShortcuts` 提供 Siri 短语建议。
- Intents 从 `CapabilityRegistry.shared` 读取运行时配置，该配置从 `UserDefaults` 加载。Intents 自身不维护状态。
- **重要**：App Intents 必须在源码中声明（而非 plist），且仅在 App 至少构建并运行一次后才会出现在快捷指令 App 中。

### 持久化

配置通过 `UserDefaults` + `Codable` 存储，不使用 SwiftData 或 Core Data。这避免了 iOS 17+ 的要求，并保持 App 最小化。

- `CapabilityRegistry` 将配置数组编码/解码到 `UserDefaults`，LLM 使用键 `llm_configs`，HTTP 使用键 `http_configs`。
- 没有迁移层；更改配置模型的属性会导致解码静默失败（配置重置为空）。

### 网络层

- `HTTPClient`（`Services/HTTPClient.swift`）是一个封装了 `URLSession` 的单例 `actor`。所有网络调用都通过它进行。
- 仅支持 `GET` 和 `POST`，可自定义请求头。
- LLM 请求使用 OpenAI 兼容的 Chat Completions 格式（`Models/LLMRequest.swift`）。请求/响应模型使用 snake_case 编码策略。

## 新增一个能力

要新增一个原子能力（例如通用 HTTP webhook）：

1. 创建一个符合 `Codable` 和 `Identifiable` 的配置结构体。
2. 在 `CapabilityRegistry` 中为新配置类型添加增删改查方法，使用独立的 `UserDefaults` 键。
3. 在新类型上实现 `AtomicCapability`，并添加一个 `execute` 方法。
4. 创建一个从 `CapabilityRegistry` 读取配置并调用 execute 方法的 `AppIntent`。
5. 添加一个用于配置编辑的 SwiftUI 视图，并将其接入 `ContentView`。

## 注意事项

- `Info.plist` 中设置了 `NSAllowsArbitraryLoads` 为 `true`，因此任意 Base URL（包括本地/http）无需 ATS 例外即可工作。
- 项目目前**没有测试目标**。如需添加测试，首先在 `project.yml` 中创建测试目标，重新生成项目，然后编写测试。
- `Info.plist` 中引用的 `SceneDelegate` 没有作为独立文件存在；App 依赖 `LLMCapabilityApp.swift` 中 `@main` 的默认 SwiftUI 生命周期。
