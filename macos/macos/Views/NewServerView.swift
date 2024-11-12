//
//  WindowView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import SwiftUI

struct NewServerView: View {
    @Environment(\.openWindow) var openWindow
    
    @ObservedObject var appState: AppState
    @ObservedObject var myServerState: ServerState = ServerState()
    
    @State private var uuid = UUID()
    @State private var status: Status = .welcoming
 
    enum Status {
        case welcoming
        case promptingForConnection
        case connecting
    }
    
    var body: some View {
        VStack {
            if (status == .connecting) {
                VStack {
                    Spacer()
                    
                    ProgressView() // Default spinner
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Divider()
                            .padding(0)
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .background(.gray.opacity(0.25))
                        
                        HStack {
                            Button(action: {
                                myServerState.disconnect()
                                status = .promptingForConnection
                            }) {
                                Text("Cancel")
                            }
                            .buttonStyle(ConnectButtonStyle())
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("Connect")
                            }
                            .buttonStyle(ConnectButtonStyle())
                            .disabled(true)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    }
                }
                .onReceive(myServerState.$status) { newStatus in
                    if (newStatus == .connected) {
                        appState.addServerState(uuid: uuid, serverState: myServerState)

                        if let window = NSApplication.shared.keyWindow {
                            window.close()
                        }
                        
                        openWindow(value: uuid)
                    }
                }
            }
            else if (status == .promptingForConnection) {
                ConnectView(onConnect: { hostname, port, nickname, realname, username, password in
                    myServerState.connect(host: hostname, port: port, nick: nickname, realname: realname, username: username, password: password)
                    status = .connecting
                }, onCancel: {
                    status = .welcoming
                })
            }
            else {
                WelcomeView(onConnect: {
                    status = .promptingForConnection
                })
                .onAppear() {
                    myServerState.getRecentServers()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                        NSApplication.shared.centerWindow()
                    }
                }
            }
        }
        .presentedWindowToolbarStyle(.unifiedCompact(showsTitle: false))
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
            NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
            NSApplication.shared.centerWindow()
        }
        .environmentObject(myServerState)
        .onDisappear() {
            if myServerState.status != .connected {
                if myServerState.status != .disconnected {
                    myServerState.disconnect()
                }
                
                appState.serverStates.removeValue(forKey: uuid)
            }
        }
    }
}

#Preview {
    NewServerView(appState: AppState())
}
