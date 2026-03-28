# Worktual AI Bot — iOS SDK

Drop-in AI chatbot for native iOS apps. Preloads in background, opens instantly — no loading screen.

## Installation

In Xcode: **File → Add Package Dependencies** → paste:

```
https://github.com/Worktual-aibot/worktual-ios-ai-bot.git
```

## SwiftUI Setup (2 Steps)

### Step 1 — Add `.worktualAIBot()` to your root view

```swift
import SwiftUI
import WorktualAIBot

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withWorktualBot(webchatId: "YOUR_WEBCHAT_ID")
        }
    }
}
```

### Step 2 — Show on button tap

```swift
import WorktualAIBot

struct HomeView: View {
    var body: some View {
        Button("Chat with AI") {
            WorktualAIBotManager.shared.show()
        }
    }
}
```

That's it. Bot opens instantly. Closes automatically when user taps close.

---

## UIKit Setup (2 Steps)

### Step 1 — Preload in AppDelegate

```swift
import WorktualAIBot

// In didFinishLaunchingWithOptions:
WorktualAIBotManager.shared.preload(in: window!, webchatId: "YOUR_WEBCHAT_ID")
```

> **Using SceneDelegate?**
> ```swift
> WorktualAIBotManager.shared.preload(in: window, webchatId: "YOUR_WEBCHAT_ID")
> ```

### Step 2 — Show on button tap

```swift
WorktualAIBotManager.shared.show()
```

---

## How It Works

1. Bot WebView loads **hidden** in background on app start
2. User taps button → `show()` makes it visible **instantly**
3. User closes chat → bot hides, stays loaded in memory
4. Next `show()` is instant again — no re-downloading

## Handle Events (Optional)

```swift
WorktualAIBotManager.shared.delegate = self

extension MyVC: WorktualAIBotDelegate {
    func worktualAIBotDidClose() {
        // Bot already hides automatically
    }
    func worktualAIBotDidBecomeReady() {
        print("Bot loaded")
    }
}
```

## Custom Branding

```swift
let config = WorktualAIBotConfig(
    webchatId: "YOUR_WEBCHAT_ID",
    loadingLogo: UIImage(named: "my_logo"),
    loadingTitle: "Support Chat",
    primaryColor: .orange
)

// SwiftUI
ContentView()
    .withWorktualBot(webchatId: "YOUR_WEBCHAT_ID", config: config)

// UIKit
WorktualAIBotManager.shared.preload(in: window!, webchatId: "YOUR_WEBCHAT_ID", config: config)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `webchatId` | `String` | Required | Your webchat ID from Worktual |
| `baseUrl` | `String` | Production URL | Custom URL if self-hosted |
| `loadingLogo` | `UIImage?` | `nil` (spinner) | Logo image |
| `loadingTitle` | `String` | `"AI Assistant"` | Loading screen title |
| `primaryColor` | `UIColor` | `#575CFF` | Progress bar colour |
| `loadingBackground` | `UIColor` | `#F8F9FB` | Background colour |

## Requirements

- iOS 14+
- Swift 5.9+

## Support

Contact your Worktual account manager for your `webchatId`.
