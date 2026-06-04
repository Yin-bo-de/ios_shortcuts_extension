import AppIntents
import Foundation

/// 快捷指令 Intent：调用 HTTP 接口
struct CallHTTPIntent: AppIntent {
    static var title: LocalizedStringResource = "调用 HTTP 接口"
    static var description = IntentDescription("通过已保存的配置发起 HTTP GET 或 POST 请求")

    /// 选择已保存的配置（可选，不选则使用默认配置）
    @Parameter(title: "配置", description: "选择已保存的 HTTP 配置")
    var config: HTTPConfigEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("发起 HTTP 请求") {
            \.$config
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let registry = CapabilityRegistry.shared

        let resolved: HTTPConfig
        if let entity = config,
           let matched = registry.httpConfigs.first(where: { $0.id.uuidString == entity.id }) {
            resolved = matched
        } else if let defaultConfig = registry.defaultHTTPConfig() {
            resolved = defaultConfig
        } else {
            throw HTTPError.missingConfig
        }

        let response = try await HTTPCapability.call(config: resolved)
        return .result(value: response)
    }
}

// MARK: - App Shortcuts Provider

struct HTTPAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CallHTTPIntent(),
            phrases: [
                "用 ${applicationName} 发起 HTTP 请求",
                "用 ${applicationName} 调用接口"
            ],
            shortTitle: "调用 HTTP",
            systemImageName: "arrow.up.arrow.down.circle"
        )
    }
}
