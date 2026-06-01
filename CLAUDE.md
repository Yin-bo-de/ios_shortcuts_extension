# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This project uses **xcodegen** to generate the `.xcodeproj` from `project.yml`. Do not commit the generated `.xcodeproj`.

```bash
# Generate the Xcode project
xcodegen generate

# Build from command line (requires Xcode)
xcodebuild -project LLMCapability.xcodeproj -scheme LLMCapability -destination 'platform=iOS Simulator,name=iPhone 15' build
```

After generating, open `LLMCapability.xcodeproj` in Xcode and run with ⌘+R. The app targets iOS 16.0+.

## Architecture

### Capability Registry Pattern

The app is built around a **capability registry** designed to support multiple atomic actions exposed to iOS Shortcuts.

- `AtomicCapability` protocol (`Capabilities/AtomicCapability.swift`) defines the contract: `capabilityID`, `displayName`, `description`.
- `CapabilityRegistry` is a singleton `ObservableObject` that manages all capability configurations. Currently it only manages `LLMConfig` instances, but it is intended to be extended for additional capability types.
- Each new capability should: (1) add a config model conforming to `Codable`, (2) implement `AtomicCapability`, (3) create an `AppIntent`, (4) register config CRUD in `CapabilityRegistry`.

### App Intents Integration (iOS 16+)

Shortcuts integration uses the modern **App Intents** framework, not an Intents extension target. This keeps the app lightweight.

- `CallLLMIntent` and `CallLLMWithSystemPromptIntent` (`Capabilities/LLM/CallLLMIntent.swift`) conform to `AppIntent`.
- `LLMAppShortcuts` provides Siri phrase suggestions.
- Intents read their runtime configuration from `CapabilityRegistry.shared`, which loads from `UserDefaults`. Intents do not maintain their own state.
- **Important**: App Intents must be declared in source (not a plist) and will only appear in the Shortcuts app after the app has been built and launched at least once.

### Persistence

Configuration is stored via `UserDefaults` + `Codable`, not SwiftData or Core Data. This avoids iOS 17+ requirements and keeps the app minimal.

- `CapabilityRegistry` encodes/decodes config arrays to `UserDefaults` under the key `llm_configs`.
- There is no migration layer; changing a config model property will cause decoding to fail silently (configs reset to empty).

### Networking

- `HTTPClient` (`Services/HTTPClient.swift`) is a singleton `actor` wrapping `URLSession`. All network calls go through it.
- It only supports `GET` and `POST` with custom headers.
- LLM requests use OpenAI-compatible Chat Completions format (`Models/LLMRequest.swift`). The request/response models use snake_case coding strategies.

## Adding a New Capability

To add a new atomic capability (e.g., generic HTTP webhook):

1. Create a config struct conforming to `Codable` and `Identifiable`.
2. Add CRUD methods to `CapabilityRegistry` for the new config type, using a distinct `UserDefaults` key.
3. Implement `AtomicCapability` on a new type with an `execute` method.
4. Create an `AppIntent` that reads the config from `CapabilityRegistry` and calls the execute method.
5. Add a SwiftUI view for config editing and wire it into `ContentView`.

## Notes

- `Info.plist` has `NSAllowsArbitraryLoads` set to `true` so arbitrary Base URLs (including local/http) work without ATS exceptions.
- The project has **no test target** currently. If adding tests, first create a test target in `project.yml`, regenerate the project, then write tests.
- The `SceneDelegate` referenced in `Info.plist` does not exist as a separate file; the app relies on the default SwiftUI lifecycle via `@main` in `LLMCapabilityApp.swift`.
