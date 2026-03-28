import UIKit

/// Configuration for the Worktual AI Bot.
public struct WorktualAIBotConfig {

    /// Your unique webchat ID provided by Worktual.
    public let webchatId: String

    /// Custom bot URL if self-hosted (defaults to Worktual production).
    public var baseUrl: String

    /// Image for the loading screen logo. If nil, a spinner is shown.
    public var loadingLogo: UIImage?

    /// Logo width in points (default: 80).
    public var loadingLogoWidth: CGFloat

    /// Logo height in points (default: 80).
    public var loadingLogoHeight: CGFloat

    /// Title shown on loading screen (default: "AI Assistant").
    public var loadingTitle: String

    /// Subtitle shown on loading screen (default: "Loading your chat...").
    public var loadingSubtitle: String

    /// Colour for progress bar & spinner (default: #575CFF).
    public var primaryColor: UIColor

    /// Loading screen background colour (default: #F8F9FB).
    public var loadingBackground: UIColor

    /// Max ms to wait before force-showing chat (default: 6000).
    public var maxLoadTimeMs: Int

    public static let defaultBaseURL =
        "https://ccaas-storage.worktual.co.uk/chat/ailivebot.html"

    public init(
        webchatId: String,
        baseUrl: String = WorktualAIBotConfig.defaultBaseURL,
        loadingLogo: UIImage? = nil,
        loadingLogoWidth: CGFloat = 80,
        loadingLogoHeight: CGFloat = 80,
        loadingTitle: String = "AI Assistant",
        loadingSubtitle: String = "Loading your chat...",
        primaryColor: UIColor = UIColor(red: 0.34, green: 0.36, blue: 1.0, alpha: 1.0),
        loadingBackground: UIColor = UIColor(red: 0.97, green: 0.98, blue: 0.98, alpha: 1.0),
        maxLoadTimeMs: Int = 6000
    ) {
        self.webchatId = webchatId
        self.baseUrl = baseUrl
        self.loadingLogo = loadingLogo
        self.loadingLogoWidth = loadingLogoWidth
        self.loadingLogoHeight = loadingLogoHeight
        self.loadingTitle = loadingTitle
        self.loadingSubtitle = loadingSubtitle
        self.primaryColor = primaryColor
        self.loadingBackground = loadingBackground
        self.maxLoadTimeMs = maxLoadTimeMs
    }

    func buildURL() -> URL? {
        let sep = baseUrl.contains("?") ? "&" : "?"
        return URL(string: "\(baseUrl)\(sep)webchatid=\(webchatId)&isHeader=1")
    }
}
