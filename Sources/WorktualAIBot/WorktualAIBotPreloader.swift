import UIKit
import WebKit

/// Pre-loads the bot WebView in the background to warm up the cache.
///
/// Call `preload()` early (e.g. in AppDelegate or your main ViewController).
/// When the user later opens the bot, it loads from cache — nearly instant.
///
/// ```swift
/// // In AppDelegate or SceneDelegate
/// let preloader = WorktualAIBotPreloader(webchatId: "YOUR_ID")
/// preloader.preload()
/// ```
public final class WorktualAIBotPreloader {

    private let config: WorktualAIBotConfig
    private var webView: WKWebView?

    public init(webchatId: String) {
        self.config = WorktualAIBotConfig(webchatId: webchatId)
    }

    public init(config: WorktualAIBotConfig) {
        self.config = config
    }

    /// Start pre-loading the bot URL in a hidden WebView.
    public func preload() {
        guard webView == nil, let url = config.buildURL() else { return }

        let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        wv.load(URLRequest(url: url))
        webView = wv
    }

    /// Clean up resources.
    public func destroy() {
        webView?.stopLoading()
        webView = nil
    }
}
