import SwiftUI

/// SwiftUI view modifier that preloads the bot when the view appears.
///
/// Usage:
/// ```swift
/// @main
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .withWorktualBot(webchatId: "YOUR_WEBCHAT_ID")
///         }
///     }
/// }
/// ```
///
/// Then show/hide from anywhere:
/// ```swift
/// Button("Chat") {
///     WorktualAIBotManager.shared.show()
/// }
/// ```
@available(iOS 14.0, *)
public struct WorktualBotModifier: ViewModifier {

    public let webchatId: String
    public let config: WorktualAIBotConfig?

    public func body(content: Content) -> some View {
        content
            .onAppear {
                // Small delay to ensure window is available
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
    /// Attach this to your root view. Then call `WorktualAIBotManager.shared.show()` to open instantly.
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
