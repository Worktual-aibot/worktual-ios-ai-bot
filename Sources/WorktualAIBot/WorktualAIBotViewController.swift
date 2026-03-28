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

    private var webView: WKWebView!
    private var loadingOverlay: LoadingOverlayView!
    private var loaderVisible = true

    // MARK: - Init

    public init(config: WorktualAIBotConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        setupLoadingOverlay()
        loadBot()
    }

    // MARK: - Setup

    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(ScriptMessageHandler(self), name: "WorktualBridge")

        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        webConfig.allowsInlineMediaPlayback = true
        webConfig.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLoadingOverlay() {
        loadingOverlay = LoadingOverlayView(config: config)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingOverlay)

        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loadingOverlay.startAnimations()
    }

    private func loadBot() {
        guard let url = config.buildURL() else { return }
        webView.load(URLRequest(url: url))
    }

    // MARK: - Loader

    private func hideLoader() {
        guard loaderVisible else { return }
        loaderVisible = false
        loadingOverlay.completeAndHide { [weak self] in
            self?.delegate?.worktualAIBotDidBecomeReady()
        }
    }

    // MARK: - JS Injection

    private func injectedJS() -> String {
        """
        (function() {
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
