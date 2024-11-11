//
//  channel.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import Core

class Channel : Codable {
    var name: String
    
    init(from dtosChannel: Core.DtosChannel) {
        self.name = dtosChannel.name
    }
}
