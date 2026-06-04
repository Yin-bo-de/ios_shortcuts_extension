import Foundation
import SwiftUI

/// 原子能力协议，所有第三方能力均需实现此协议
protocol AtomicCapability {
    /// 能力唯一标识
    static var capabilityID: String { get }
    /// 能力显示名称
    static var displayName: String { get }
    /// 能力描述
    static var description: String { get }
}

/// 能力注册表，管理所有已注册的原子能力配置
final class CapabilityRegistry: ObservableObject {
    static let shared = CapabilityRegistry()

    @Published var llmConfigs: [LLMConfig] = []
    @Published var httpConfigs: [HTTPConfig] = []

    private let configsKey = "llm_configs"
    private let httpConfigsKey = "http_configs"

    private init() {
        loadConfigs()
        loadHTTPConfigs()
    }

    // MARK: - LLM Configs

    func addLLMConfig(_ config: LLMConfig) {
        if let index = llmConfigs.firstIndex(where: { $0.id == config.id }) {
            llmConfigs[index] = config
        } else {
            llmConfigs.append(config)
        }
        saveConfigs()
    }

    func removeLLMConfig(at offsets: IndexSet) {
        llmConfigs.remove(atOffsets: offsets)
        saveConfigs()
    }

    func removeLLMConfig(_ config: LLMConfig) {
        llmConfigs.removeAll { $0.id == config.id }
        saveConfigs()
    }

    func config(withID id: UUID) -> LLMConfig? {
        llmConfigs.first { $0.id == id }
    }

    func defaultConfig() -> LLMConfig? {
        llmConfigs.first
    }

    // MARK: - HTTP Configs

    func addHTTPConfig(_ config: HTTPConfig) {
        if let index = httpConfigs.firstIndex(where: { $0.id == config.id }) {
            httpConfigs[index] = config
        } else {
            httpConfigs.append(config)
        }
        saveHTTPConfigs()
    }

    func removeHTTPConfig(at offsets: IndexSet) {
        httpConfigs.remove(atOffsets: offsets)
        saveHTTPConfigs()
    }

    func removeHTTPConfig(_ config: HTTPConfig) {
        httpConfigs.removeAll { $0.id == config.id }
        saveHTTPConfigs()
    }

    func httpConfig(withID id: UUID) -> HTTPConfig? {
        httpConfigs.first { $0.id == id }
    }

    func defaultHTTPConfig() -> HTTPConfig? {
        httpConfigs.first
    }

    // MARK: - Persistence

    private func loadConfigs() {
        guard let data = UserDefaults.standard.data(forKey: configsKey),
              let configs = try? JSONDecoder().decode([LLMConfig].self, from: data)
        else {
            return
        }
        llmConfigs = configs
    }

    private func saveConfigs() {
        guard let data = try? JSONEncoder().encode(llmConfigs) else { return }
        UserDefaults.standard.set(data, forKey: configsKey)
    }

    private func loadHTTPConfigs() {
        guard let data = UserDefaults.standard.data(forKey: httpConfigsKey),
              let configs = try? JSONDecoder().decode([HTTPConfig].self, from: data)
        else {
            return
        }
        httpConfigs = configs
    }

    private func saveHTTPConfigs() {
        guard let data = try? JSONEncoder().encode(httpConfigs) else { return }
        UserDefaults.standard.set(data, forKey: httpConfigsKey)
    }
}
