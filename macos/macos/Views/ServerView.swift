//
//  ContentView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-08.
//

import SwiftUI
import SwiftUIIntrospect
import Core

struct ServerView: View {
    @Environment(\.openWindow) var openWindow
    
    @SwiftUI.StateObject private var myServerState: ServerState
    
    @SwiftUI.State private var parentSplitViewColumnVisibility = NavigationSplitViewVisibility.doubleColumn
    @SwiftUI.State private var childSplitViewColumnVisibility = NavigationSplitViewVisibility.detailOnly
    @SwiftUI.State private var toast: Toast?
    
    init(uuid: UUID, appState: AppState) {
        self._myServerState = StateObject(wrappedValue: appState.serverStates[uuid]!)
    }
    
    var channelToolbarItems : some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            VStack(alignment: .center) {
                HStack(alignment: .center) {
                    Text(myServerState.selectedServer!.hostname)
                    Button(action: {                        
                        if let window = NSApplication.shared.keyWindow {
                            window.close()
                        }
                        
                        openWindow(id: "new-server")
                    }) {
                        Label("Leave", systemImage: "xmark")
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if (myServerState.status == .connected) {
                VStack {
                    NavigationSplitView(columnVisibility: $parentSplitViewColumnVisibility) {
                        ChannelsView()
                            .navigationSplitViewColumnWidth(min: 320, ideal: 320)
                            .toolbar(removing: .sidebarToggle)
                            .toolbar {
                                if (parentSplitViewColumnVisibility != .detailOnly) {
                                    channelToolbarItems
                                }
                            }
                    } detail: {
                        if (myServerState.selectedChannel != nil) {
                            NavigationSplitView(columnVisibility: $childSplitViewColumnVisibility) {
                                ChannelView(name: myServerState.selectedChannel!)
                                    .navigationSplitViewColumnWidth(min: 320, ideal: 320)
                            } detail: {
                                MessagesView()
                            }
                        } else {
                            MessagesView()
                        }
                    }
                    .toolbarRole(.editor)
                    .navigationSplitViewStyle(.balanced)
                    .introspect(.navigationSplitView, on: .macOS(.v13, .v14, .v15)) { splitview in
                         if let delegate = splitview.delegate as? NSSplitViewController {
                             delegate.splitViewItems.first?.canCollapse = false
                         }
                    }
                }
                .frame(minWidth: 720, minHeight: 480)
                .onAppear() {
                    NSApp.mainWindow?.standardWindowButton(.zoomButton)?.isHidden = false
                    NSApp.mainWindow?.standardWindowButton(.miniaturizeButton)?.isHidden = false
                   
                    if let screen = NSApp.mainWindow?.screen ?? NSScreen.main {
                        NSApp.mainWindow?.setFrame(screen.visibleFrame, display: true)
                    }
                }
                .onAppear() {
                    myServerState.loadChannels()
                }
                .onChange(of: myServerState.notice) {
                    if let notice = $0 {
                        toast = Toast(style: .info, message: notice, duration: 30, width: 480)
                    } else {
                        toast = nil
                    }
                }
            }
            else if (myServerState.status == .connecting) {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .padding()
                    
                    Text("Connecting...")
                        .font(.title)
                        .padding()
                    
                    Button(action: {
                        myServerState.connect(
                            host: myServerState.selectedServer!.hostname,
                            port: myServerState.selectedServer!.port,
                            nick: myServerState.selectedServer!.nickname,
                            realname: myServerState.selectedServer!.realname,
                            username: myServerState.selectedServer!.username,
                            password: myServerState.selectedServer!.password
                        )
                    }) {
                        Text("Try re-connecting")
                    }
                    .buttonStyle(ConnectButtonStyle())
                    
                    Button(action: {
                        myServerState.disconnect()
                    }) {
                        Text("Disconnect")
                    }
                    .buttonStyle(LinkButtonStyle())
                    .foregroundStyle(.red)
                }
            }
            else {
                Text("Not connected. That's weird...")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    myServerState.connect(
                        host: myServerState.selectedServer!.hostname,
                        port: myServerState.selectedServer!.port,
                        nick: myServerState.selectedServer!.nickname,
                        realname: myServerState.selectedServer!.realname,
                        username: myServerState.selectedServer!.username,
                        password: myServerState.selectedServer!.password
                    )
                }) {
                    Text("Reconnect")
                }
                .buttonStyle(ConnectButtonStyle())
            }
        }
        .onDisappear() {
            myServerState.disconnect()
        }
        .environmentObject(myServerState)
        .toast(toast: $toast)
    }
}

#Preview {
    ServerView(uuid: UUID(), appState: AppState())
}
