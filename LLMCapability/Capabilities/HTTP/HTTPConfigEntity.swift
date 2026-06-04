import AppIntents
import Foundation

/// AppEntity 封装 HTTP 配置，用于快捷指令下拉选择
struct HTTPConfigEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "HTTP 配置"

    typealias DefaultQuery = HTTPConfigQuery
    static var defaultQuery: HTTPConfigQuery { HTTPConfigQuery() }

    let id: String
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }
}

// MARK: - EntityQuery

struct HTTPConfigQuery: EntityQuery {
    func entities(for identifiers: [HTTPConfigEntity.ID]) async throws -> [HTTPConfigEntity] {
        CapabilityRegistry.shared.httpConfigs
            .filter { identifiers.contains($0.id.uuidString) }
            .map { HTTPConfigEntity(id: $0.id.uuidString, name: $0.name) }
    }

    func suggestedEntities() async throws -> [HTTPConfigEntity] {
        allHTTPConfigEntities()
    }

    func suggestedResults() async throws -> [HTTPConfigEntity] {
        allHTTPConfigEntities()
    }

    private func allHTTPConfigEntities() -> [HTTPConfigEntity] {
        CapabilityRegistry.shared.httpConfigs.map {
            HTTPConfigEntity(id: $0.id.uuidString, name: $0.name)
        }
    }
}

// MARK: - EntityStringQuery (支持按名称搜索)

extension HTTPConfigQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [HTTPConfigEntity] {
        CapabilityRegistry.shared.httpConfigs
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { HTTPConfigEntity(id: $0.id.uuidString, name: $0.name) }
    }
}
