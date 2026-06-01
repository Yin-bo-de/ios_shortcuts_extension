import SwiftUI

struct LLMConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var registry = CapabilityRegistry.shared

    var config: LLMConfig?

    @State private var name: String
    @State private var baseURL: String
    @State private var apiKey: String
    @State private var modelName: String
    @State private var systemPrompt: String
    @State private var temperature: Double
    @State private var timeout: Double
    @State private var showingTestAlert = false
    @State private var testResult: String?
    @State private var isTesting = false

    init(config: LLMConfig?) {
        self.config = config
        _name = State(initialValue: config?.name ?? "")
        _baseURL = State(initialValue: config?.baseURL ?? "")
        _apiKey = State(initialValue: config?.apiKey ?? "")
        _modelName = State(initialValue: config?.modelName ?? "gpt-3.5-turbo")
        _systemPrompt = State(initialValue: config?.systemPrompt ?? "You are a helpful assistant.")
        _temperature = State(initialValue: config?.temperature ?? 0.7)
        _timeout = State(initialValue: config?.timeout ?? 60.0)
    }

    var body: some View {
        Form {
            Section(header: Text("基本信息")) {
                TextField("配置名称", text: $name)
                TextField("Base URL", text: $baseURL)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                SecureField("API Key", text: $apiKey)
                    .autocapitalization(.none)
            }

            Section(header: Text("模型参数")) {
                TextField("模型名称", text: $modelName)
                    .autocapitalization(.none)
                VStack(alignment: .leading) {
                    Text("Temperature: \(String(format: "%.2f", temperature))")
                    Slider(value: $temperature, in: 0...2, step: 0.1)
                }
            }

            Section(header: Text("系统提示词")) {
                TextEditor(text: $systemPrompt)
                    .frame(minHeight: 80)
            }

            Section {
                Button(action: testConnection) {
                    HStack {
                        Text("测试连接")
                        Spacer()
                        if isTesting {
                            ProgressView()
                        }
                    }
                }
                .disabled(isTesting || baseURL.isEmpty || name.isEmpty)

                if let result = testResult {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(result.contains("成功") ? .green : .red)
                }
            }
        }
        .navigationTitle(config == nil ? "新增配置" : "编辑配置")
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
                .disabled(name.isEmpty || baseURL.isEmpty)
            }
        }
    }

    private func saveConfig() {
        let newConfig = LLMConfig(
            id: config?.id ?? UUID(),
            name: name,
            baseURL: baseURL,
            apiKey: apiKey,
            modelName: modelName,
            systemPrompt: systemPrompt,
            temperature: temperature,
            timeout: timeout
        )
        registry.addLLMConfig(newConfig)
        dismiss()
    }

    private func testConnection() {
        guard !baseURL.isEmpty else { return }
        isTesting = true
        testResult = nil

        Task {
            do {
                let testConfig = LLMConfig(
                    name: name,
                    baseURL: baseURL,
                    apiKey: apiKey,
                    modelName: modelName,
                    systemPrompt: systemPrompt,
                    temperature: temperature,
                    timeout: timeout
                )
                let _ = try await LLMCapability.call(config: testConfig, prompt: "Hello")
                await MainActor.run {
                    testResult = "连接成功！模型响应正常。"
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = "连接失败: \(error.localizedDescription)"
                    isTesting = false
                }
            }
        }
    }
}
