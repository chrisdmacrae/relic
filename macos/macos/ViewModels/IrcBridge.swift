//
//  IrcContext.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import Foundation
import Core

class IrcBridge : ObservableObject {
    var bridge: Core.ObjcIrcBridgeProtocol = Core.ObjcNewIrcBridge()!
    
    func getRecentServers() -> [Server] {
        let payload = bridge.getRecentServersPayload()
        
        if let data = payload.data(using: .utf8) {
            do {
                let servers = try JSONDecoder().decode([Server].self, from: data)
            
                return servers
            } catch {
                print("Error parsing recent servers: \(error)")
            }
        }
        
        return []
    }
    
    func getAvailableChannels() -> [String] {
        let payload = bridge.getAvailableChannelsPayload()
        
        if let data = payload.data(using: .utf8) {
            do {
                let channels = try JSONDecoder().decode([String].self, from: data)
            
                return channels
            } catch {
                print("Error parsing available channels: \(error)")
            }
        }
        
        return []
    }
    
    func getPinnedChannels() -> [String] {
        let payload = bridge.getPinnedChannelsPayload()
        
        if let data = payload.data(using: .utf8) {
            do {
                let channels = try JSONDecoder().decode([String].self, from: data)
            
                return channels
            } catch {
                print("Error parsing pinned channels: \(error)")
            }
        }
        
        return []
    }
    
    func getChannel(channel: String) -> Channel? {
        let payload = bridge.getChannelPayload(channel)
        
        if let data = payload.data(using: .utf8) {
            do {
                let channel = try JSONDecoder().decode(Channel.self, from: data)
            
                return channel
            } catch {
                print("Error parsing channel: \(error), \(payload)")
            }
        }
        
        return nil
    }
    
    func connect(
        host: String,
        port: Int,
        nick: String,
        realname: String,
        username: String?,
        password: String?
    ) {
        do {
            print("Connecting to \(host):\(port) as \(nick) with realname \(realname)")
            print("Username: \(username ?? "nil")")
            print("Password: \(password ?? "nil")")
            
            if (username != nil && username != "" && password != nil && password != "") {
                try self.bridge.connect(
                    withAuth: host,
                    port: port,
                    nickname: nick,
                    realname: realname,
                    username: username!,
                    password: password!
                )
            } else {
                try self.bridge.connect(
                    host,
                    port: port,
                    nick: nick,
                    realname: realname
                )
            }
        } catch(let error) {
            print("Error connecting: \(error)")
        }
    }
    
    func joinChannel(_ channel: String) {
        do {
            try bridge.joinChannel(channel)
        } catch {
            print("Error joining channel: \(error)")
        }
    }
    
    func pinChannel(channel: String) {
        do {
            try bridge.pinChannel(channel)
        } catch {
            print("Error pinning channel: \(error)")
        }
    }
    
    func unpinChannel(channel: String) {
        do {
            try bridge.unpinChannel(channel)
        } catch {
            print("Error unpinning channel: \(error)")
        }
    }
    
    func disconnect() {
        bridge.disconnect()
    }
}
