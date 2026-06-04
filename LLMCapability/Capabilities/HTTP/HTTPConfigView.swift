import SwiftUI

struct HTTPConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var registry = CapabilityRegistry.shared

    var config: HTTPConfig?

    @State private var name: String
    @State private var url: String
    @State private var method: HTTPMethod
    @State private var headerItems: [HeaderItem]
    @State private var body: String
    @State private var timeout: Double
    @State private var showingTestAlert = false
    @State private var testResult: String?
    @State private var isTesting = false

    init(config: HTTPConfig?) {
        self.config = config
        _name = State(initialValue: config?.name ?? "")
        _url = State(initialValue: config?.url ?? "")
        _method = State(initialValue: config?.method ?? .get)
        _body = State(initialValue: config?.body ?? "")
        _timeout = State(initialValue: config?.timeout ?? 60.0)

        let headers = config?.headers ?? [:]
        let items = headers.map { HeaderItem(key: $0.key, value: $0.value) }
        _headerItems = State(initialValue: items.isEmpty ? [HeaderItem()] : items)
    }

    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                TextField("配置名称", text: $name)
                TextField("请求 URL", text: $url)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                Picker("请求方法", selection: $method) {
                    ForEach(HTTPMethod.allCases, id: \.self) { method in
                        Text(method.rawValue).tag(method)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("请求头 (Headers)")) {
                ForEach($headerItems) { $item in
                    HStack {
                        TextField("Key", text: $item.key)
                        Text(":")
                            .foregroundColor(.secondary)
                        TextField("Value", text: $item.value)
                    }
                }
                .onDelete(perform: deleteHeader)

                Button(action: addHeader) {
                    Label("添加 Header", systemImage: "plus")
                }
            }

            if method == .post {
                Section(header: Text("请求体 (Body)")) {
                    TextEditor(text: $body)
                        .frame(minHeight: 100)
                }
            }

            Section {
                Button(action: testConnection) {
                    HStack {
                        Text("测试请求")
                        Spacer()
                        if isTesting {
                            ProgressView()
                        }
                    }
                }
                .disabled(isTesting || url.isEmpty || name.isEmpty)

                if let result = testResult {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(result.contains("成功") ? .green : .red)
                }
            }
        }
        .navigationTitle(config == nil ? "新增 HTTP 配置" : "编辑 HTTP 配置")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    saveConfig()
                }
                .disabled(name.isEmpty || url.isEmpty)
            }
        }
    }

    private var currentHeaders: [String: String] {
        var dict: [String: String] = [:]
        for item in headerItems {
            if !item.key.isEmpty {
                dict[item.key] = item.value
            }
        }
        return dict
    }

    private func addHeader() {
        headerItems.append(HeaderItem())
    }

    private func deleteHeader(at offsets: IndexSet) {
        headerItems.remove(atOffsets: offsets)
        if headerItems.isEmpty {
            headerItems.append(HeaderItem())
        }
    }

    private func saveConfig() {
        let newConfig = HTTPConfig(
            id: config?.id ?? UUID(),
            name: name,
            url: url,
            method: method,
            headers: currentHeaders,
            body: body,
            timeout: timeout
        )
        registry.addHTTPConfig(newConfig)
        dismiss()
    }

    private func testConnection() {
        guard !url.isEmpty else { return }
        isTesting = true
        testResult = nil

        Task {
            do {
                let testConfig = HTTPConfig(
                    name: name,
                    url: url,
                    method: method,
                    headers: currentHeaders,
                    body: body,
                    timeout: timeout
                )
                let response = try await HTTPCapability.call(config: testConfig)
                let preview = String(response.prefix(200))
                await MainActor.run {
                    testResult = "请求成功！响应预览: \(preview)"
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = "请求失败: \(error.localizedDescription)"
                    isTesting = false
                }
            }
        }
    }
}

// MARK: - HeaderItem

struct HeaderItem: Identifiable, Equatable {
    let id = UUID()
    var key: String
    var value: String

    init(key: String = "", value: String = "") {
        self.key = key
        self.value = value
    }
}
