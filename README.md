# Worktual AI Bot — iOS SDK

Drop-in AI chatbot for native iOS apps. Preloads in background, opens instantly.

## Installation (Swift Package Manager)

In Xcode: **File → Add Package Dependencies** → paste:

```
https://github.com/Worktual-aibot/worktual-ios-ai-bot.git
```

## Usage (Recommended — Instant Open)

Preload the bot hidden in your app window. When the user taps your button, the bot opens **instantly** — no loading screen.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: ...) -> Bool {
        // Preload bot in background (hidden, loads WebView silently)
        WorktualAIBotManager.shared.preload(
            in: window!,
            webchatId: "YOUR_WEBCHAT_ID"
        )
        return true
    }
}
```

```swift
class HomeViewController: UIViewController {

    @IBAction func chatButtonTapped(_ sender: Any) {
        // Opens instantly — no loading screen!
        WorktualAIBotManager.shared.show()
    }
}
```

The bot hides automatically when the user closes it, and stays loaded for instant re-open.

To handle close events:

```swift
WorktualAIBotManager.shared.delegate = self

extension HomeViewController: WorktualAIBotDelegate {
    func worktualAIBotDidClose() {
        // Bot is already hidden, do any cleanup here
    }
}
```

## Alternative — Present as Modal (shows loading screen)

```swift
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

WorktualAIBotManager.shared.preload(in: window!, webchatId: "", config: config)
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
