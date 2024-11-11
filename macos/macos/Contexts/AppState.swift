//
//  AppState.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import Foundation
import Core

class AppState : ObservableObject {
    @Published var status: Status = .welcoming
    @Published var messages = [Core.ModelsMessage]()
    @Published var notice: String?
    
    @Published var recentServers: [Server] = []
    @Published var selectedServer: Server?
    
    @Published var isLoadingChannels = false
    @Published var channels: [String]?
    @Published var pinnedChannels = [String]()
    @Published var isLoadingSelectedChannel = false
    @Published var selectedChannel: String?
    
    enum Status {
        case welcoming
        case promptingForConnection
        case connecting
        case connected
    }
    
    private var ircContext: IrcContext
    
    init(ircContext: IrcContext) {
        self.ircContext = ircContext
        self.ircContext.bridge.setConnectionDelegate(ConnectionDelegate(context: self.ircContext, appState: self))
        self.ircContext.bridge.setChannelDelegate(ChannelDelegate(context: self.ircContext, appState: self))
    }
    
    func connect(host: String, port: Int, nick: String, realname: String, password: String?) {
        status = .connecting
        
        DispatchQueue.global(qos: .background).async {
            self.ircContext.connect(
                host: host,
                port: port,
                nick: nick,
                realname: realname,
                password: password
            )
            
            self.ircContext.bridge.startBackgroundHealthcheck()
        }
    }
    
    func disconnect() {
        ircContext.disconnect()
        
        status = .welcoming
    }
    
    func getRecentServers() {
        recentServers = ircContext.getRecentServers()
    }
    
    func loadChannels() {
        isLoadingChannels = true
        
        DispatchQueue.global(qos: .background).async {
            let pinnedChannels = self.ircContext.getPinnedChannels()
            
            DispatchQueue.main.async {
                self.pinnedChannels = pinnedChannels.sorted()
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            let channels = self.ircContext.getAvailableChannels()
            
            DispatchQueue.main.async {
                self.channels = channels.sorted()
                self.isLoadingChannels = false
            }
        }
    }
    
    func joinChannel(channel: String) {
        var mutableChannel = channel
        if (!mutableChannel.starts(with: "#")) {
            mutableChannel = "#" + mutableChannel
        }
        
        selectedChannel = mutableChannel
    }
    
    
    func pinChannel(channel: String) {
        ircContext.pinChannel(channel: channel)
        
        pinnedChannels = ircContext.getPinnedChannels()
    }
    
    func unpinChannel(channel: String) {
        ircContext.unpinChannel(channel: channel)
        
        pinnedChannels = ircContext.getPinnedChannels()
    }
    
    func sendMessage(_ channel: String, message: String) {
        ircContext.bridge.sendMessage(channel, message: message)
    }
    
    // MARK: ConnectionDelegate
    
    class ConnectionDelegate : NSObject, Core.DelegatesClientConnectionDelegateProtocol {
        private var context: IrcContext
        private var appState: AppState
        
        init(context: IrcContext, appState: AppState) {
            self.context = context
            self.appState = appState
        }
        
        func onConnected() {
            print("Connected")
            
            self.appState.status = .connected
        }
        
        func onDisconnected() {
            print("Disconnected")
            
            self.appState.status = .welcoming
        }
        
        func onNotice(_ notice: String?) {
            DispatchQueue.main.async {
                self.appState.notice = notice
            }
        }
    }
    
    // MARK: ChannelDelegate
    
    class ChannelDelegate : NSObject, Core.DelegatesClientChannelDelegateProtocol {
        private var context: IrcContext
        private var appState: AppState
        
        init(context: IrcContext, appState: AppState) {
            self.context = context
            self.appState = appState
        }
        
        func onConnected(_ channel: String?) {
            print("Connected to \(channel!)")
        }
        
        func onDisconnected(_ channel: String?) {
            print("Disconnected from \(channel!)")
        }
        
        func onMessageReceived(_ channel: String?, nick: String?, text: String?) {
            DispatchQueue.main.async {
                self.appState.messages.append(Core.ModelsMessage(channel, nick: nick, text: text)!)
            }
        }
    }
}
