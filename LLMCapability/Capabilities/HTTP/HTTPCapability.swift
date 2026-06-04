import Foundation

/// HTTP 原子能力实现，负责执行通用 HTTP 请求
struct HTTPCapability: AtomicCapability {
    static let capabilityID = "com.atombridge.http"
    static let displayName = "调用 HTTP 接口"
    static let description = "通过 GET 或 POST 方式调用任意 HTTP 接口"

    /// 执行 HTTP 请求
    static func call(config: HTTPConfig) async throws -> String {
        guard let url = URL(string: config.url) else {
            throw HTTPError.invalidURL
        }

        let (data, response): (Data, HTTPURLResponse)

        switch config.method {
        case .get:
            (data, response) = try await HTTPClient.shared.get(
                url: url,
                headers: config.headers
            )
        case .post:
            let bodyData = config.body.data(using: .utf8) ?? Data()
            (data, response) = try await HTTPClient.shared.post(
                url: url,
                headers: config.headers,
                body: bodyData
            )
        }

        guard (200...299).contains(response.statusCode) else {
            throw HTTPError.statusCode(response.statusCode)
        }

        // 尝试按 UTF-8 解码响应体，如果失败则返回原始 data 的 base64
        if let text = String(data: data, encoding: .utf8) {
            return text
        } else {
            return data.base64EncodedString()
        }
    }
}

enum HTTPError: Error, LocalizedError {
    case invalidURL
    case statusCode(Int)
    case invalidResponse
    case missingConfig

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .statusCode(let code):
            return "HTTP 错误码: \(code)"
        case .invalidResponse:
            return "无效的响应"
        case .missingConfig:
            return "未找到 HTTP 配置，请先在 App 内添加配置"
        }
    }
}
