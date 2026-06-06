import AppIntents
import Foundation

/// 快捷指令 Intent：调用 LLM 大模型
struct CallLLMIntent: AppIntent {
    static var title: LocalizedStringResource = "调用 LLM"
    static var description = IntentDescription("通过配置的云端大语言模型获取回复")

    /// 用户输入的提示词
    @Parameter(title: "提示词", description: "发送给大模型的内容")
    var prompt: String

    /// 选择已保存的配置（可选，不选则使用默认配置）
    @Parameter(title: "配置", description: "选择已保存的 LLM 配置")
    var config: LLMConfigEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("询问 LLM：\(\.$prompt)") {
            \.$config
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let registry = CapabilityRegistry.shared

        let resolved: LLMConfig
        if let entity = config,
           let matched = registry.llmConfigs.first(where: { $0.id.uuidString == entity.id }) {
            resolved = matched
        } else if let defaultConfig = registry.defaultConfig() {
            resolved = defaultConfig
        } else {
            throw LLMError.missingConfig
        }

        let response = try await LLMCapability.call(config: resolved, prompt: prompt)
        return .result(value: response)
    }
}

/// 快捷指令 Intent：调用 LLM（带系统提示词覆盖）
struct CallLLMWithSystemPromptIntent: AppIntent {
    static var title: LocalizedStringResource = "调用 LLM（自定义系统提示）"
    static var description = IntentDescription("使用自定义系统提示词调用大语言模型")

    @Parameter(title: "提示词", description: "发送给大模型的用户内容")
    var prompt: String

    @Parameter(title: "系统提示词", description: "覆盖默认的系统提示词")
    var systemPrompt: String

    @Parameter(title: "配置", description: "选择已保存的 LLM 配置")
    var config: LLMConfigEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("用系统提示「\(\.$systemPrompt)」询问 LLM：\(\.$prompt)") {
            \.$config
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let registry = CapabilityRegistry.shared

        var resolved: LLMConfig
        if let entity = config,
           let matched = registry.llmConfigs.first(where: { $0.id.uuidString == entity.id }) {
            resolved = matched
        } else if let defaultConfig = registry.defaultConfig() {
            resolved = defaultConfig
        } else {
            throw LLMError.missingConfig
        }

        resolved.systemPrompt = systemPrompt
        let response = try await LLMCapability.call(config: resolved, prompt: prompt)
        return .result(value: response)
    }
}

// MARK: - App Shortcuts Provider

struct AppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CallLLMIntent(),
            phrases: [
                "用 ${applicationName} 调用 LLM",
                "用 ${applicationName} 问大模型"
            ],
            shortTitle: "调用 LLM",
            systemImageName: "bubble.left.and.bubble.right"
        )
    }
}
