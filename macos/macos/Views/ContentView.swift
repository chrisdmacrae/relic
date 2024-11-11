//
//  ContentView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-08.
//

import SwiftUI
import Core

struct ContentView: View {
    @ObservedObject var appState: AppState
    
    @SwiftUI.State private var splitViewColumnVisibility = NavigationSplitViewVisibility.doubleColumn
    @SwiftUI.State private var toast: Toast?
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    var body: some View {
        VStack {
            if (appState.status == .connected) {
                NavigationSplitView(columnVisibility: $splitViewColumnVisibility) {
                  ChannelsView()
                        .toolbar {
                            ToolbarItem {
                                HStack(alignment: .center) {
                                    Button(action: {
                                        appState.disconnect()
                                    }) {
                                        Label("Leave", systemImage: "xmark")
                                    }
                                    Text(appState.selectedServer!.hostname)
                                }
                            }
                        }
                        .frame(minWidth: 320)
                } detail: {
                   MessagesView(navigationSplitViewVisibility: $splitViewColumnVisibility)
                }
                .frame(minWidth: 720, minHeight: 480)
                .onAppear() {
                    NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = false
                    NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = false
                   
                    if let screen = NSApp.mainWindow?.screen ?? NSScreen.main {
                        NSApp.mainWindow?.setFrame(screen.visibleFrame, display: true)
                    }
                }
                .onChange(of: appState.selectedChannel) { channel in
                    if (channel == nil) {
                        return
                    }
                    
                    appState.isLoadingSelectedChannel = true
                    DispatchQueue.global(qos: .background).async {
                        appState.joinChannel(channel: channel!)
                        
                        DispatchQueue.main.async {
                            appState.isLoadingSelectedChannel = false
                        }
                    }
                }
                .onAppear() {
                    appState.loadChannels()
                }
                .onChange(of: appState.notice) {
                    if let notice = $0 {
                        toast = Toast(style: .info, message: notice, duration: 30, width: 480)
                    } else {
                        toast = nil
                    }
                }
            }
            else {
                VStack {
                    if (appState.status == .connecting) {
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
                                        appState.disconnect()
                                        appState.status = .promptingForConnection
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
                    }
                    else if (appState.status == .promptingForConnection) {
                        ConnectView(onConnect: { hostname, port, nickname, realname, password in
                            appState.connect(host: hostname, port: port, nick: nickname, realname: realname, password: password)
                        }, onCancel: {
                            appState.status = .welcoming
                        })
                    }
                    else {
                        WelcomeView(onConnect: {
                            appState.status = .promptingForConnection
                        })
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                                NSApplication.shared.centerWindow()
                            }
                        }
                    }
                }
                .presentedWindowToolbarStyle(.unifiedCompact(showsTitle: false))
                .onAppear() {
                    NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                    NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                }
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification)) { _ in
                    NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                    NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    NSApplication.shared.centerWindow()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = true
                    NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    NSApplication.shared.centerWindow()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    appState.disconnect()
                }
            }
        }
        .onDisappear() {
            appState.status = .welcoming
        }
        .toast(toast: $toast)
    }
}

#Preview {
    ContentView(appState: AppState(ircContext: IrcContext()))
}
