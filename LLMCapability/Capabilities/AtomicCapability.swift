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

    private let configsKey = "llm_configs"

    private init() {
        loadConfigs()
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
}
