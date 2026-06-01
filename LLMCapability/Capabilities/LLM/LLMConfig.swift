import Foundation

/// LLM 配置模型，支持 Codable 持久化
struct LLMConfig: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var baseURL: String
    var apiKey: String
    var modelName: String
    var systemPrompt: String
    var temperature: Double
    var timeout: TimeInterval

    init(
        id: UUID = UUID(),
        name: String,
        baseURL: String,
        apiKey: String,
        modelName: String = "gpt-3.5-turbo",
        systemPrompt: String = "You are a helpful assistant.",
        temperature: Double = 0.7,
        timeout: TimeInterval = 60.0
    ) {
        self.id = id
        self.name = name
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.modelName = modelName
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.timeout = timeout
    }
}
