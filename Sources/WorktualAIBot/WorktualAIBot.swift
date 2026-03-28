import UIKit

/// Convenience launcher for the Worktual AI Bot (UIKit only).
/// For SwiftUI, use `.withWorktualBot(webchatId:)` modifier instead.
public enum WorktualBotLauncher {

    /// Launch the bot as a full-screen modal from the given view controller.
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
