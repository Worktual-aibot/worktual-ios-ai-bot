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
///                 .worktualAIBot(webchatId: "YOUR_WEBCHAT_ID")
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
struct WorktualAIBotModifier: ViewModifier {

    let webchatId: String
    let config: WorktualAIBotConfig?

    func body(content: Content) -> some View {
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
    ///     .worktualAIBot(webchatId: "YOUR_WEBCHAT_ID")
    /// ```
    func worktualAIBot(
        webchatId: String,
        config: WorktualAIBotConfig? = nil
    ) -> some View {
        modifier(WorktualAIBotModifier(webchatId: webchatId, config: config))
    }
}
