import Foundation

// MARK: - Request

struct LLMChatRequest: Codable {
    let model: String
    let messages: [LLMMessage]
    let temperature: Double

    init(model: String, messages: [LLMMessage], temperature: Double = 0.7) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
    }
}

struct LLMMessage: Codable {
    let role: String
    let content: String

    init(role: String, content: String) {
        self.role = role
        self.content = content
    }

    static func system(_ content: String) -> LLMMessage {
        LLMMessage(role: "system", content: content)
    }

    static func user(_ content: String) -> LLMMessage {
        LLMMessage(role: "user", content: content)
    }

    static func assistant(_ content: String) -> LLMMessage {
        LLMMessage(role: "assistant", content: content)
    }
}

// MARK: - Response

struct LLMChatResponse: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [LLMChoice]?
    let usage: LLMUsage?
    let error: LLMErrorDetail?
}

struct LLMChoice: Codable {
    let index: Int?
    let message: LLMMessage?
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct LLMUsage: Codable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

struct LLMErrorDetail: Codable {
    let message: String?
    let type: String?
    let code: String?
}

// MARK: - Errors

enum LLMError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case networkError(Error)
    case noChoices
    case encodingError
    case missingConfig

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的请求地址"
        case .invalidResponse:
            return "服务器返回了无法解析的响应"
        case .apiError(let message):
            return "API 错误: \(message)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .noChoices:
            return "模型未返回有效内容"
        case .encodingError:
            return "请求编码失败"
        case .missingConfig:
            return "未找到有效的 LLM 配置，请在 App 中先添加配置"
        }
    }
}
