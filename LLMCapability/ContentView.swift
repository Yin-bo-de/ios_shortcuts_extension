import SwiftUI

struct ContentView: View {
    @StateObject private var registry = CapabilityRegistry.shared
    @State private var showingAddConfig = false
    @State private var selectedConfig: LLMConfig?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("LLM 配置")) {
                    ForEach(registry.llmConfigs) { config in
                        Button(action: {
                            selectedConfig = config
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
                    .onDelete(perform: deleteConfig)
                }

                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
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
                    Button(action: {
                        showingAddConfig = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddConfig) {
                NavigationStack {
                    LLMConfigView(config: nil)
                }
            }
            .sheet(item: $selectedConfig) { config in
                NavigationStack {
                    LLMConfigView(config: config)
                }
            }
        }
    }

    private func deleteConfig(at offsets: IndexSet) {
        registry.removeLLMConfig(at: offsets)
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
                    Text("4. 选择「调用 LLM」操作")
                    Text("5. 输入提示词，选择已保存的配置")
                    Text("6. 运行快捷指令即可获取模型回复")
                }
                .font(.body)

                Divider()

                Text("注意事项")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("• 首次使用需在 App 内添加至少一个 LLM 配置")
                    Text("• 确保目标 Base URL 可被设备访问")
                    Text("• API Key 仅保存在本地，不会上传到任何服务器")
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
