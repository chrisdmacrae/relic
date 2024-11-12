//
//  AppState.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import Foundation
import Core

class ServerState : ObservableObject {
    @Published var status: Status = .disconnected
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
        case disconnected
        case connecting
        case connected
    }
    
    private var ircBridge = IrcBridge()
    
    init() {
        self.ircBridge.bridge.setConnectionDelegate(ConnectionDelegate(context: self.ircBridge, serverState: self))
        self.ircBridge.bridge.setChannelDelegate(ChannelDelegate(context: self.ircBridge, serverState: self))
    }
    
    func connect(host: String, port: Int, nick: String, realname: String, username: String?, password: String?) {
        status = .connecting
        
        DispatchQueue.global(qos: .background).async {
            self.ircBridge.connect(
                host: host,
                port: port,
                nick: nick,
                realname: realname,
                username: username,
                password: password
            )
            
            self.ircBridge.bridge.startBackgroundHealthcheck()
        }
    }
    
    func disconnect() {
        ircBridge.disconnect()
        
        self.status = .disconnected
    }
    
    func getRecentServers() {
        recentServers = ircBridge.getRecentServers()
    }
    
    func loadChannels() {
        isLoadingChannels = true
        
        DispatchQueue.global(qos: .background).async {
            let pinnedChannels = self.ircBridge.getPinnedChannels()
            
            DispatchQueue.main.async {
                self.pinnedChannels = pinnedChannels.sorted()
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            let channels = self.ircBridge.getAvailableChannels()
            
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
        
        ircBridge.joinChannel(selectedChannel!)
    }
    
    func getChannel(channel: String) -> Channel? {
        return ircBridge.getChannel(channel: channel)
    }
    
    func pinChannel(channel: String) {
        ircBridge.pinChannel(channel: channel)
        
        pinnedChannels = ircBridge.getPinnedChannels()
    }
    
    func unpinChannel(channel: String) {
        ircBridge.unpinChannel(channel: channel)
        
        pinnedChannels = ircBridge.getPinnedChannels()
    }
    
    func sendMessage(_ channel: String, message: String) {
        ircBridge.bridge.sendMessage(channel, message: message)
        
        messages.append(Core.ModelsMessage(channel, nick: selectedServer!.nickname, text: message)!)
    }
    
    // MARK: ConnectionDelegate
    
    class ConnectionDelegate : NSObject, Core.DelegatesClientConnectionDelegateProtocol {
        private var context: IrcBridge
        private var serverState: ServerState
        
        init(context: IrcBridge, serverState: ServerState) {
            self.context = context
            self.serverState = serverState
        }
        
        func onConnected() {
            print("Connected")
            
            DispatchQueue.main.async {
                self.serverState.status = .connected
            }
        }
        
        func onDisconnected() {
            print("Disconnected")
            
            DispatchQueue.main.async {
                self.serverState.status = .disconnected
            }
        }
        
        func onNotice(_ notice: String?) {
            DispatchQueue.main.async {
                self.serverState.notice = notice
            }
        }
    }
    
    // MARK: ChannelDelegate
    
    class ChannelDelegate : NSObject, Core.DelegatesClientChannelDelegateProtocol {
        private var context: IrcBridge
        private var serverState: ServerState
        
        init(context: IrcBridge, serverState: ServerState) {
            self.context = context
            self.serverState = serverState
        }
        
        func onConnected(_ channel: String?) {
            print("Connected to \(channel!)")
        }
        
        func onDisconnected(_ channel: String?) {
            print("Disconnected from \(channel!)")
        }
        
        func onMessageReceived(_ channel: String?, nick: String?, text: String?) {
            DispatchQueue.main.async {
                self.serverState.messages.append(Core.ModelsMessage(channel, nick: nick, text: text)!)
            }
        }
    }
}
