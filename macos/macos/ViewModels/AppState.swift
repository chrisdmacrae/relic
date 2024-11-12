//
//  AppState.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import Foundation

class AppState : ObservableObject {
    @Published var serverStates = Dictionary<UUID, ServerState>()
    
    func addServerState(uuid: UUID, serverState: ServerState) {
        serverStates[uuid] = serverState
        self.objectWillChange.send()
    }
}
