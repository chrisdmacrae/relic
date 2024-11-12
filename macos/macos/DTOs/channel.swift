//
//  channel.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import Core

class Channel : Codable {
    var name: String
    var topic: String
    var nicksCommaDelimited: String
    var isPinned = false
    
    var nicks: [String] {
        return String(nicksCommaDelimited).split(separator: ",").map({ String($0) })
    }
    
    init(from dtosChannel: Core.DtosChannel) {
        self.name = dtosChannel.name
        self.topic = dtosChannel.topic
        self.nicksCommaDelimited = dtosChannel.nicksCommaDelimited
        self.isPinned = dtosChannel.isPinned
    }
}
