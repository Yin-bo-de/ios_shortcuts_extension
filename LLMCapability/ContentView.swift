import SwiftUI

struct ContentView: View {
    @StateObject private var registry = CapabilityRegistry.shared
    @State private var showingAddLLMConfig = false
    @State private var showingAddHTTPConfig = false
    @State private var selectedLLMConfig: LLMConfig?
    @State private var selectedHTTPConfig: HTTPConfig?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("LLM 配置")) {
                    ForEach(registry.llmConfigs) { config in
                        Button(action: {
                            selectedLLMConfig = config
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(config.name)
                                        .font(.headline)
                                    Text(config.baseURL)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteLLMConfig)
                }

                Section(header: Text("HTTP 配置")) {
                    ForEach(registry.httpConfigs) { config in
                        Button(action: {
                            selectedHTTPConfig = config
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(config.name)
                                        .font(.headline)
                                    Text("\(config.method.rawValue) \(config.url)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteHTTPConfig)
                }

                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.1.0")
                            .foregroundColor(.secondary)
                    }
                    NavigationLink("快捷指令使用说明") {
                        ShortcutGuideView()
                    }
                }
            }
            .navigationTitle("原子能力配置")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingAddLLMConfig = true
                        }) {
                            Label("新增 LLM 配置", systemImage: "bubble.left.and.bubble.right")
                        }
                        Button(action: {
                            showingAddHTTPConfig = true
                        }) {
                            Label("新增 HTTP 配置", systemImage: "arrow.up.arrow.down.circle")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLLMConfig) {
                NavigationStack {
                    LLMConfigView(config: nil)
                }
            }
            .sheet(isPresented: $showingAddHTTPConfig) {
                NavigationStack {
                    HTTPConfigView(config: nil)
                }
            }
            .sheet(item: $selectedLLMConfig) { config in
                NavigationStack {
                    LLMConfigView(config: config)
                }
            }
            .sheet(item: $selectedHTTPConfig) { config in
                NavigationStack {
                    HTTPConfigView(config: config)
                }
            }
        }
    }

    private func deleteLLMConfig(at offsets: IndexSet) {
        registry.removeLLMConfig(at: offsets)
    }

    private func deleteHTTPConfig(at offsets: IndexSet) {
        registry.removeHTTPConfig(at: offsets)
    }
}

struct ShortcutGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("在快捷指令中使用")
                    .font(.title2)
                    .bold()

                VStack(alignment: .leading, spacing: 8) {
                    Text("1. 打开 iOS 快捷指令 App")
                    Text("2. 创建新快捷指令或编辑现有指令")
                    Text("3. 在操作列表中搜索本 App 名称")
                    Text("4. 选择需要的操作（调用 LLM 或调用 HTTP 接口）")
                    Text("5. 选择已保存的配置")
                    Text("6. 运行快捷指令即可获取结果")
                }
                .font(.body)

                Divider()

                Text("LLM 能力")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("• 首次使用需在 App 内添加至少一个 LLM 配置")
                    Text("• 确保目标 Base URL 可被设备访问")
                    Text("• API Key 仅保存在本地，不会上传到任何服务器")
                }
                .font(.body)
                .foregroundColor(.secondary)

                Divider()

                Text("HTTP 能力")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("• 支持 GET 和 POST 两种请求方式")
                    Text("• Headers 和 Body 在 App 内预先配置")
                    Text("• 快捷指令中仅需选择配置即可发起请求")
                    Text("• 响应内容以字符串形式返回给快捷指令")
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("使用说明")
        .navigationBarTitleDisplayMode(.inline)
    }
}
