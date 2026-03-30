import UIKit
import WebKit

/// Drop-in AI chatbot view controller for iOS.
///
/// Present it modally or push onto a navigation stack:
/// ```swift
/// let bot = WorktualAIBotViewController(
///     config: WorktualAIBotConfig(webchatId: "YOUR_ID")
/// )
/// bot.delegate = self
/// present(bot, animated: true)
/// ```
public final class WorktualAIBotViewController: UIViewController {

    // MARK: - Public

    public let config: WorktualAIBotConfig
    public weak var delegate: WorktualAIBotDelegate?

    // MARK: - Private

    private var webView: WKWebView?
    private var loadingOverlay: LoadingOverlayView?
    private var loaderVisible = true

    // MARK: - Init

    public init(config: WorktualAIBotConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "WorktualBridge")
        loadingOverlay?.cleanup()
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = config.statusBarColor
        setupWebView()
        setupLoadingOverlay()
        loadBot()
    }

    public override var prefersStatusBarHidden: Bool { false }
    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(ScriptMessageHandler(self), name: "WorktualBridge")

        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        webConfig.allowsInlineMediaPlayback = true
        webConfig.mediaTypesRequiringUserActionForPlayback = []

        let wv = WKWebView(frame: .zero, configuration: webConfig)
        wv.navigationDelegate = self
        wv.scrollView.bounces = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wv)

        // Use safe area so the bot header/close button stays visible
        // on all iPhones (notch, Dynamic Island, etc.)
        NSLayoutConstraint.activate([
            wv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        webView = wv
    }

    private func setupLoadingOverlay() {
        let overlay = LoadingOverlayView(config: config)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        overlay.startAnimations()
        loadingOverlay = overlay
    }

    private func loadBot() {
        guard let url = config.buildURL() else { return }
        webView?.load(URLRequest(url: url))
    }

    // MARK: - Loader

    private func hideLoader() {
        guard loaderVisible else { return }
        loaderVisible = false
        loadingOverlay?.completeAndHide { [weak self] in
            self?.delegate?.worktualAIBotDidBecomeReady()
        }
    }

    // MARK: - JS Injection

    private func injectedJS() -> String {
        """
        (function() {
            // Polyfill: bot HTML calls ReactNativeWebView.postMessage()
            // Forward those messages to our native iOS bridge
            window.ReactNativeWebView = {
                postMessage: function(msg) {
                    window.webkit.messageHandlers.WorktualBridge.postMessage(msg);
                }
            };

            // Also intercept window.postMessage for iframe-based bots
            var origPostMessage = window.postMessage;
            window.postMessage = function(msg, origin) {
                try {
                    if (typeof msg === 'string') {
                        window.webkit.messageHandlers.WorktualBridge.postMessage(msg);
                    } else {
                        window.webkit.messageHandlers.WorktualBridge.postMessage(JSON.stringify(msg));
                    }
                } catch(e) {}
                return origPostMessage.call(window, msg, origin);
            };

            // Poll for chat content readiness
            var t = setInterval(function() {
                var m = document.querySelectorAll(
                    '.message, .chat-message, .msg-content, [class*="message"]'
                );
                var i = document.querySelector('input[placeholder], textarea[placeholder]');
                if (m.length > 0 || i) {
                    clearInterval(t);
                    window.webkit.messageHandlers.WorktualBridge.postMessage(
                        JSON.stringify({ type: "webchat_ready" })
                    );
                }
            }, 200);

            // Timeout fallback
            setTimeout(function() {
                clearInterval(t);
                window.webkit.messageHandlers.WorktualBridge.postMessage(
                    JSON.stringify({ type: "webchat_ready" })
                );
            }, \(config.maxLoadTimeMs));
        })();
        """
    }

    // MARK: - Message Handler (prevent retain cycle)

    private class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
        private weak var parent: WorktualAIBotViewController?

        init(_ parent: WorktualAIBotViewController) {
            self.parent = parent
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let body = message.body as? String,
                  let data = body.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }

            parent?.delegate?.worktualAIBotDidReceiveMessage(json)

            if let type = json["type"] as? String {
                switch type {
                case "webchat_ready":
                    parent?.hideLoader()
                case "webchat_end":
                    parent?.delegate?.worktualAIBotDidClose()
                default:
                    break
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension WorktualAIBotViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(injectedJS())
    }
}
