# Worktual AI Bot — iOS SDK

Drop-in AI chatbot for native iOS apps. One line to launch.

## Installation (Swift Package Manager)

In Xcode: **File → Add Package Dependencies** → paste:

```
https://github.com/user/worktual-ios-ai-bot.git
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/user/worktual-ios-ai-bot.git", from: "1.0.0")
]
```

## Usage

### Simple — Launch as modal (one line)

```swift
WorktualAIBot.launch(from: self, webchatId: "YOUR_WEBCHAT_ID")
```

### With close handling

```swift
class MyViewController: UIViewController, WorktualAIBotDelegate {

    func openBot() {
        WorktualAIBot.launch(
            from: self,
            webchatId: "YOUR_WEBCHAT_ID",
            delegate: self
        )
    }

    func worktualAIBotDidClose() {
        dismiss(animated: true)
    }
}
```

### Advanced — Use the ViewController directly

```swift
let bot = WorktualAIBotViewController(
    config: WorktualAIBotConfig(webchatId: "YOUR_WEBCHAT_ID")
)
bot.delegate = self
navigationController?.pushViewController(bot, animated: true)
```

### Instant Loading (Preload)

Preload the bot in AppDelegate so it opens instantly:

```swift
// In AppDelegate or SceneDelegate
let preloader = WorktualAIBotPreloader(webchatId: "YOUR_WEBCHAT_ID")
preloader.preload()

// Later — bot opens from cache, near instant
WorktualAIBot.launch(from: self, webchatId: "YOUR_WEBCHAT_ID")
```

## Configuration

```swift
let config = WorktualAIBotConfig(
    webchatId: "YOUR_WEBCHAT_ID",
    loadingLogo: UIImage(named: "my_logo"),
    loadingTitle: "Support Chat",
    primaryColor: .orange,
    loadingBackground: UIColor(red: 1, green: 0.97, blue: 0.94, alpha: 1)
)

WorktualAIBot.launch(from: self, webchatId: "", config: config, delegate: self)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `webchatId` | `String` | Required | Your webchat ID from Worktual |
| `baseUrl` | `String` | Production URL | Custom URL if self-hosted |
| `loadingLogo` | `UIImage?` | `nil` (spinner) | Logo image for loading screen |
| `loadingTitle` | `String` | `"AI Assistant"` | Loading screen title |
| `loadingSubtitle` | `String` | `"Loading your chat..."` | Loading screen subtitle |
| `primaryColor` | `UIColor` | `#575CFF` | Progress bar colour |
| `loadingBackground` | `UIColor` | `#F8F9FB` | Loading screen background |
| `maxLoadTimeMs` | `Int` | `6000` | Max wait before force-showing chat |

## Requirements

- iOS 14+
- Swift 5.9+

## Support

Contact your Worktual account manager for your `webchatId`.
