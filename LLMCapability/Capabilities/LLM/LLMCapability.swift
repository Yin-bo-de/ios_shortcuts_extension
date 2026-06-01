import Foundation

/// LLM 原子能力实现，负责构造请求并调用远程模型
struct LLMCapability: AtomicCapability {
    static let capabilityID = "com.llm-capability.llm"
    static let displayName = "调用 LLM"
    static let description = "通过 HTTP 调用云端大语言模型"

    /// 执行 LLM 调用
    static func call(
        config: LLMConfig,
        prompt: String
    ) async throws -> String {
        guard let url = URL(string: config.baseURL) else {
            throw LLMError.invalidURL
        }

        let messages = [
            LLMMessage.system(config.systemPrompt),
            LLMMessage.user(prompt)
        ]

        let requestBody = LLMChatRequest(
            model: config.modelName,
            messages: messages,
            temperature: config.temperature
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let bodyData: Data
        do {
            bodyData = try encoder.encode(requestBody)
        } catch {
            throw LLMError.encodingError
        }

        var headers = [
            "Authorization": "Bearer \(config.apiKey)",
            "Content-Type": "application/json"
        ]

        // 某些本地部署服务不需要 Authorization，保留兼容
        if config.apiKey.isEmpty {
            headers.removeValue(forKey: "Authorization")
        }

        let (data, response) = try await HTTPClient.shared.post(
            url: url,
            headers: headers,
            body: bodyData
        )

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let chatResponse = try decoder.decode(LLMChatResponse.self, from: data)

        if let errorDetail = chatResponse.error, let message = errorDetail.message {
            throw LLMError.apiError(message)
        }

        guard let choice = chatResponse.choices?.first,
              let content = choice.message?.content else {
            throw LLMError.noChoices
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
