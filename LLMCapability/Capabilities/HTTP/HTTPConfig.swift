import Foundation

/// HTTP 请求方法枚举
enum HTTPMethod: String, Codable, CaseIterable, Equatable {
    case get = "GET"
    case post = "POST"
}

/// HTTP 配置模型，支持 Codable 持久化
struct HTTPConfig: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var url: String
    var method: HTTPMethod
    var headers: [String: String]
    var body: String
    var timeout: TimeInterval

    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: String = "",
        timeout: TimeInterval = 60.0
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
}
