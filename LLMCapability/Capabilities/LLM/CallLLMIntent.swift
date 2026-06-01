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
    @Parameter(title: "配置名称", description: "选择已保存的 LLM 配置")
    var configName: String?

    static var parameterSummary: some ParameterSummary {
        Summary("询问 LLM：\($prompt)") {
            \.$configName
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let registry = CapabilityRegistry.shared

        let config: LLMConfig
        if let name = configName,
           let matched = registry.llmConfigs.first(where: { $0.name == name }) {
            config = matched
        } else if let defaultConfig = registry.defaultConfig() {
            config = defaultConfig
        } else {
            throw LLMError.missingConfig
        }

        let response = try await LLMCapability.call(config: config, prompt: prompt)
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

    @Parameter(title: "配置名称", description: "选择已保存的 LLM 配置")
    var configName: String?

    static var parameterSummary: some ParameterSummary {
        Summary("用系统提示「\($systemPrompt)」询问 LLM：\($prompt)") {
            \.$configName
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let registry = CapabilityRegistry.shared

        var config: LLMConfig
        if let name = configName,
           let matched = registry.llmConfigs.first(where: { $0.name == name }) {
            config = matched
        } else if let defaultConfig = registry.defaultConfig() {
            config = defaultConfig
        } else {
            throw LLMError.missingConfig
        }

        config.systemPrompt = systemPrompt
        let response = try await LLMCapability.call(config: config, prompt: prompt)
        return .result(value: response)
    }
}

// MARK: - App Shortcuts Provider

struct LLMAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CallLLMIntent(),
            phrases: [
                "用 LLM 回答 \(.prompt)",
                "问大模型 \(.prompt)"
            ],
            shortTitle: "调用 LLM",
            systemImageName: "bubble.left.and.bubble.right"
        )
    }
}
