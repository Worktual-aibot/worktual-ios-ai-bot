import Foundation

/// Delegate for Worktual AI Bot events.
public protocol WorktualAIBotDelegate: AnyObject {
    /// Called when the chat content is fully loaded and visible.
    func worktualAIBotDidBecomeReady()

    /// Called when the user closes the chat.
    func worktualAIBotDidClose()

    /// Called on every message received from the chat WebView.
    func worktualAIBotDidReceiveMessage(_ data: [String: Any])
}

// Default implementations — only onClose is required
public extension WorktualAIBotDelegate {
    func worktualAIBotDidBecomeReady() {}
    func worktualAIBotDidReceiveMessage(_ data: [String: Any]) {}
}
