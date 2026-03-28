/// Convenience launcher for the Worktual AI Bot.
///
/// ```swift
/// WorktualAIBot.launch(from: self, webchatId: "YOUR_ID")
/// ```
public enum WorktualAIBot {

    /// Launch the bot as a full-screen modal from the given view controller.
    ///
    /// - Parameters:
    ///   - viewController: The presenting view controller.
    ///   - webchatId: Your webchat ID from Worktual.
    ///   - config: Optional full configuration (overrides webchatId if provided).
    ///   - delegate: Optional delegate for bot events.
    ///   - animated: Whether to animate the presentation (default: true).
    public static func launch(
        from viewController: UIViewController,
        webchatId: String,
        config: WorktualAIBotConfig? = nil,
        delegate: WorktualAIBotDelegate? = nil,
        animated: Bool = true
    ) {
        let botConfig = config ?? WorktualAIBotConfig(webchatId: webchatId)
        let botVC = WorktualAIBotViewController(config: botConfig)
        botVC.delegate = delegate
        viewController.present(botVC, animated: animated)
    }
}

import UIKit
