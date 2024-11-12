import SwiftUI
import Core

@main
struct macosApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup("relirc", id: "new-server") {
            NewServerView(appState: appState) // Passing the binding to the dictionary
                .frame(minWidth: 720, minHeight: 480)
                .frame(maxWidth: 720, maxHeight: 480)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowResizability(.contentSize)
        
        WindowGroup("Server", for: UUID.self) { id in
            VStack {
                if let uuid = id.wrappedValue { // Unwrap the Binding<UUID?> to get the UUID
                    ServerView(uuid: uuid, appState: appState)
                } else {
                    Text("Invalid server ID")
                }
            }
            .frame(minWidth: 720, minHeight: 480)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
    }
}
