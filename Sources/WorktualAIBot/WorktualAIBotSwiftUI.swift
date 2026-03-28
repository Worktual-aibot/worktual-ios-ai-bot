import SwiftUI

@available(iOS 14.0, *)
public struct WorktualBotModifier: ViewModifier {

    public let webchatId: String
    public let config: WorktualAIBotConfig?

    public init(webchatId: String, config: WorktualAIBotConfig? = nil) {
        self.webchatId = webchatId
        self.config = config
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    WorktualAIBotManager.shared.preload(
                        webchatId: webchatId,
                        config: config
                    )
                }
            }
    }
}

@available(iOS 14.0, *)
public extension View {

    /// Preload the Worktual AI Bot in the background.
    /// Then call `WorktualAIBotManager.shared.show()` to open instantly.
    ///
    /// ```swift
    /// ContentView()
    ///     .withWorktualBot(webchatId: "YOUR_WEBCHAT_ID")
    /// ```
    func withWorktualBot(
        webchatId: String,
        config: WorktualAIBotConfig? = nil
    ) -> some View {
        modifier(WorktualBotModifier(webchatId: webchatId, config: config))
    }
}
