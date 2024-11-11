//
//  macosApp.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-08.
//

import SwiftUI
import Core

@main
struct macosApp: App {
    @ObservedObject var appState: AppState
    
    init() {
        let ircContext = IrcContext()
        
        self._appState = ObservedObject(wrappedValue: AppState(ircContext: ircContext))
    }

    var body: some Scene {
        // Main Content WindowGroup, shown only if connected
        WindowGroup("relirc") {
            ContentView(appState: appState)
                .frame(minWidth: 720, minHeight: 480)
                .frame(maxWidth: appState.status == .connected ? .infinity : 720)
                .frame(maxHeight: appState.status == .connected ? .infinity : 480)
                .environmentObject(appState)
                .onAppear() {
                    appState.getRecentServers()
                }
        }
        .windowResizability(appState.status == .connected ? .automatic : .contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

