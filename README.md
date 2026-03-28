# Worktual AI Bot — iOS SDK

Drop-in AI chatbot for native iOS apps. Preloads in background, opens instantly — no loading screen.

## Installation

In Xcode: **File → Add Package Dependencies** → paste:

```
https://github.com/Worktual-aibot/worktual-ios-ai-bot.git
```

## Setup (2 Steps)

### Step 1 — Preload in AppDelegate (runs once on app start)

```swift
import WorktualAIBot

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Bot loads silently in background — user sees nothing
        WorktualAIBotManager.shared.preload(
            in: window!,
            webchatId: "YOUR_WEBCHAT_ID"
        )
        return true
    }
}
```

> **Using SceneDelegate?**
> ```swift
> func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
>     guard let windowScene = (scene as? UIWindowScene) else { return }
>     let window = UIWindow(windowScene: windowScene)
>     // ... your setup ...
>     WorktualAIBotManager.shared.preload(in: window, webchatId: "YOUR_WEBCHAT_ID")
> }
> ```

### Step 2 — Show/Hide on button tap

```swift
import WorktualAIBot

class HomeViewController: UIViewController {

    @IBAction func chatButtonTapped(_ sender: Any) {
        // Opens INSTANTLY — no loading screen!
        WorktualAIBotManager.shared.show()
    }
}
```

That's it. The bot closes itself automatically when the user taps the close button inside the chat.

## How It Works

1. `preload()` loads the bot WebView **hidden** in your app window on app start
2. By the time the user taps the chat button, the bot is **already fully loaded**
3. `show()` just makes it visible — **instant, zero delay**
4. When user closes the chat, the bot hides but **stays loaded** in memory
5. Next `show()` is instant again — no re-downloading

## Handle Close Events (Optional)

```swift
class HomeViewController: UIViewController, WorktualAIBotDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        WorktualAIBotManager.shared.delegate = self
    }

    func worktualAIBotDidClose() {
        // Bot already hides automatically
        // Add any custom logic here
    }

    func worktualAIBotDidBecomeReady() {
        print("Bot is loaded and ready")
    }
}
```

## Custom Branding

```swift
let config = WorktualAIBotConfig(
    webchatId: "YOUR_WEBCHAT_ID",
    loadingLogo: UIImage(named: "my_logo"),
    loadingTitle: "Support Chat",
    primaryColor: .orange,
    loadingBackground: UIColor(red: 1, green: 0.97, blue: 0.94, alpha: 1)
)

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
