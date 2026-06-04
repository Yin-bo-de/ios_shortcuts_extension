# 项目进展 - AtomBridge iOS App

## 项目概览

**项目名称**: AtomBridge
**目标**: 为 iOS 快捷指令提供第三方原子能力扩展，支持 LLM 调用与通用 HTTP 接口调用
**技术栈**: SwiftUI + App Intents + URLSession
**部署目标**: iOS 16.0+

---

## 已完成功能

### 1. 项目架构搭建 ✅
- [x] 确定技术选型（SwiftUI + App Intents + UserDefaults）
- [x] 设计原子能力注册表架构
- [x] 创建项目目录结构
- [x] 创建 `project.yml`（xcodegen 配置文件）
- [x] 创建 `Info.plist`
- [x] 编写项目文档（README.md、CLAUDE.md）

### 2. 核心服务层 ✅
- [x] 实现 `HTTPClient`（基于 URLSession 的异步 HTTP 客户端，支持 GET/POST）
- [x] 定义 OpenAI 兼容的请求/响应模型（LLMChatRequest、LLMChatResponse）
- [x] 定义 LLM 错误类型（LLMError）
- [x] 定义 HTTP 错误类型（HTTPError）

### 3. LLM 原子能力 ✅
- [x] 定义 `AtomicCapability` 协议
- [x] 实现 `CapabilityRegistry` 配置管理单例
- [x] 创建 `LLMConfig` 配置模型（支持 Codable 持久化）
- [x] 实现 `LLMCapability` 执行逻辑（OpenAI 兼容格式调用）
- [x] 实现配置管理 UI（`LLMConfigView`）
- [x] 支持测试连接功能

### 4. HTTP 原子能力 ✅
- [x] 创建 `HTTPConfig` 配置模型（支持 GET/POST、Headers、Body、Codable 持久化）
- [x] 扩展 `CapabilityRegistry` 支持 HTTP 配置的 CRUD 与独立持久化
- [x] 实现 `HTTPCapability` 执行逻辑（通用 GET/POST 请求，返回响应字符串）
- [x] 实现 HTTP 配置管理 UI（`HTTPConfigView`，支持动态 Headers 编辑、方法切换）
- [x] 支持 HTTP 请求测试功能

### 5. App Intents 快捷指令集成 ✅
- [x] 创建 `CallLLMIntent`（基础 LLM 调用）
- [x] 创建 `CallLLMWithSystemPromptIntent`（支持自定义系统提示词）
- [x] 创建 `CallHTTPIntent`（通用 HTTP 请求调用）
- [x] 实现 `LLMAppShortcuts` Siri 短语建议
- [x] 实现 `HTTPAppShortcuts` Siri 短语建议
- [x] 支持配置名称选择和默认配置回退

### 6. 主界面 ✅
- [x] 创建 `ContentView`（配置管理列表，支持 LLM 与 HTTP 双能力）
- [x] 实现配置的增删改查
- [x] 添加快捷指令使用说明页面（涵盖 LLM 与 HTTP 两种能力）
- [x] 创建 App 入口（`LLMCapabilityApp.swift`）

### 7. 品牌升级 ✅
- [x] App 名称从 `LLMCapability` / `LLM快捷指令` 升级为 `AtomBridge`
- [x] 更新 Bundle Identifier 匹配新品牌

---

## 文件清单

```
apple_app/
├── CLAUDE.md                                       # Claude Code 工作指南
├── README.md                                       # 项目说明与使用指南
├── progress.md                                     # 本文件 - 项目进展
├── project.yml                                     # xcodegen 项目配置
└── LLMCapability/
    ├── LLMCapabilityApp.swift                      # App 入口
    ├── ContentView.swift                           # 主界面
    ├── Info.plist                                  # 应用配置
    ├── Assets.xcassets/                            # 资源目录（待填充）
    ├── Capabilities/
    │   ├── AtomicCapability.swift                  # 原子能力协议与注册表
    │   ├── LLM/
    │   │   ├── LLMCapability.swift                 # LLM 能力实现
    │   │   ├── CallLLMIntent.swift                 # LLM 快捷指令 Intent
    │   │   ├── LLMConfig.swift                     # LLM 配置数据模型
    │   │   ├── LLMConfigView.swift                 # LLM 配置编辑界面
    │   │   └── LLMConfigEntity.swift               # LLM AppEntity（快捷指令下拉选择）
    │   └── HTTP/
    │       ├── HTTPCapability.swift                # HTTP 能力实现
    │       ├── CallHTTPIntent.swift                # HTTP 快捷指令 Intent
    │       ├── HTTPConfig.swift                    # HTTP 配置数据模型
    │       ├── HTTPConfigView.swift                # HTTP 配置编辑界面
    │       └── HTTPConfigEntity.swift              # HTTP AppEntity（快捷指令下拉选择）
    ├── Services/
    │   └── HTTPClient.swift                        # HTTP 客户端
    └── Models/
        └── LLMRequest.swift                        # 请求/响应模型
```

---

## 待办事项

### 高优先级
- [ ] 补充 AppIcon 和应用图标
- [ ] 创建 LaunchScreen（启动画面）
- [ ] 在 Xcode 环境中编译验证（当前仅完成代码编写，未实际编译）
- [ ] 添加单元测试（HTTPClient、LLM 解析逻辑）

### 中优先级
- [ ] 支持流式响应（streaming）
- [ ] 增加更多 LLM 参数支持（max_tokens、top_p 等）
- [ ] 支持 PUT/DELETE/PATCH 等更多 HTTP 方法
- [ ] HTTP 响应支持 JSON 字段提取（如通过 JSONPath 快捷指令只取某个字段）

### 低优先级
- [ ] 配置导入/导出功能
- [ ] 支持多个 LLM 服务商的预设模板
- [ ] 添加使用统计/历史记录
- [ ] App Store 上架准备（隐私政策、截图等）

---

## 已知问题

1. **编译验证待完成**: 当前环境无完整 Xcode，代码尚未经过实际编译。需要 Xcode 15+ 环境执行 `xcodegen generate && xcodebuild` 验证。
2. **Assets 为空**: `Assets.xcassets` 目录已创建但无实际图标资源。
3. **无测试覆盖**: 目前无测试目标，需要补充。

---

## 技术决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| UI 框架 | SwiftUI | 声明式、代码量少、符合轻量化要求 |
| 快捷指令集成 | App Intents | iOS 16+ 原生支持，无需额外 Extension Target |
| 持久化 | UserDefaults + Codable | 兼容 iOS 16，无需 Core Data/SwiftData 复杂度 |
| 网络层 | URLSession (原生) | 无需第三方依赖，保持轻量 |
| 项目生成 | xcodegen | 避免提交 `.xcodeproj`，减少 Git 冲突 |
| 快捷指令参数设计 | 选择已保存配置 | 保护敏感信息（URL/Key/Body），简化快捷指令界面 |
| Body 传递策略 | 原始 UTF-8 字符串 | 最大灵活性，支持 JSON/form-data/纯文本等任意格式 |

---

## 最后更新

**日期**: 2026-06-05
**状态**: 编码完成（LLM + HTTP 双能力），待编译验证
