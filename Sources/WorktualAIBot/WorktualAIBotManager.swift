import UIKit

/**
 Singleton manager for instant bot loading.

 Preloads the bot once, keeps it alive, and shows/hides instantly.
 Same approach as the React Native "always mounted hidden" pattern.

 Usage:
 ```swift
 // 1. Preload early (e.g. in AppDelegate or main ViewController)
 WorktualAIBotManager.shared.preload(
     in: window!,
     webchatId: "YOUR_WEBCHAT_ID"
 )

 // 2. Show instantly when user taps button (no loading screen!)
 WorktualAIBotManager.shared.show()

 // 3. Hide when user closes (bot stays loaded for next open)
 WorktualAIBotManager.shared.hide()

 // 4. Clean up when done
 WorktualAIBotManager.shared.destroy()
 ```
 */
public final class WorktualAIBotManager: NSObject {

    public static let shared = WorktualAIBotManager()

    private var botViewController: WorktualAIBotViewController?
    private var containerView: UIView?
    private var hostWindow: UIWindow?
    private var isShowing = false
    public weak var delegate: WorktualAIBotDelegate?

    private override init() {
        super.init()
    }

    // MARK: - Public API

    /// Preload the bot in the background. Call this early in your app lifecycle.
    /// The bot WebView loads hidden — when you call `show()`, it appears instantly.
    ///
    /// - Parameters:
    ///   - window: The app's main UIWindow to attach the hidden bot to.
    ///   - webchatId: Your webchat ID from Worktual.
    ///   - config: Optional full configuration.
    public func preload(
        in window: UIWindow,
        webchatId: String,
        config: WorktualAIBotConfig? = nil
    ) {
        guard botViewController == nil else { return } // Already preloaded

        let botConfig = config ?? WorktualAIBotConfig(webchatId: webchatId)
        hostWindow = window

        let botVC = WorktualAIBotViewController(config: botConfig)
        botVC.delegate = self

        // Create hidden container
        let container = UIView(frame: window.bounds)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.isHidden = true

        // Add bot VC's view to container
        botVC.view.frame = container.bounds
        botVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(botVC.view)

        // Add to window (loads WebView in background)
        window.addSubview(container)

        botViewController = botVC
        containerView = container
    }

    /// Preload the bot without passing a window. Automatically finds the key window.
    /// Works with both UIKit and SwiftUI apps.
    ///
    /// - Parameters:
    ///   - webchatId: Your webchat ID from Worktual.
    ///   - config: Optional full configuration.
    public func preload(
        webchatId: String,
        config: WorktualAIBotConfig? = nil
    ) {
        guard let window = Self.findKeyWindow() else { return }
        preload(in: window, webchatId: webchatId, config: config)
    }

    private static func findKeyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }

    /// Show the bot instantly. Must call `preload` first.
    public func show() {
        containerView?.isHidden = false
        hostWindow?.bringSubviewToFront(containerView!)
        isShowing = true
    }

    /// Hide the bot. The WebView stays alive for instant re-open.
    public func hide() {
        containerView?.isHidden = true
        isShowing = false
    }

    /// Whether the bot is currently visible.
    public var isVisible: Bool {
        return isShowing
    }

    /// Destroy the bot and free all resources.
    public func destroy() {
        hide()
        containerView?.removeFromSuperview()
        botViewController = nil
        containerView = nil
        hostWindow = nil
    }
}

// MARK: - Internal delegate forwarding

extension WorktualAIBotManager: WorktualAIBotDelegate {
    public func worktualAIBotDidBecomeReady() {
        delegate?.worktualAIBotDidBecomeReady()
    }

    public func worktualAIBotDidClose() {
        hide()
        delegate?.worktualAIBotDidClose()
    }

    public func worktualAIBotDidReceiveMessage(_ data: [String: Any]) {
        delegate?.worktualAIBotDidReceiveMessage(data)
    }
}
