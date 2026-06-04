import AppIntents
import Foundation

/// AppEntity 封装 LLM 配置，用于快捷指令下拉选择
/// 敏感字段（apiKey 等）不暴露给 Intent 框架，仅通过 ID 回查完整配置
struct LLMConfigEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "LLM 配置"

    typealias DefaultQuery = LLMConfigQuery
    static var defaultQuery: LLMConfigQuery { LLMConfigQuery() }

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }
}

// MARK: - EntityQuery

struct LLMConfigQuery: EntityQuery {
    func entities(for identifiers: [LLMConfigEntity.ID]) async throws -> [LLMConfigEntity] {
        CapabilityRegistry.shared.llmConfigs
            .filter { identifiers.contains($0.id.uuidString) }
            .map { LLMConfigEntity(id: $0.id.uuidString, name: $0.name) }
    }

    func suggestedEntities() async throws -> [LLMConfigEntity] {
        allLLMConfigEntities()
    }

    func suggestedResults() async throws -> [LLMConfigEntity] {
        allLLMConfigEntities()
    }

    private func allLLMConfigEntities() -> [LLMConfigEntity] {
        CapabilityRegistry.shared.llmConfigs.map {
            LLMConfigEntity(id: $0.id.uuidString, name: $0.name)
        }
    }
}

// MARK: - EntityStringQuery (支持按名称搜索)

extension LLMConfigQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [LLMConfigEntity] {
        CapabilityRegistry.shared.llmConfigs
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { LLMConfigEntity(id: $0.id.uuidString, name: $0.name) }
    }
}
