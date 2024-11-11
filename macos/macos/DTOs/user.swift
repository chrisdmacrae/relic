//
//  user.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import Core

// Wrapper for DtosUser
struct User: Codable {
    var nick: String
    var realName: String
    var host: String

    // Initialize from DtosUser instance
    init(from dtosUser: DtosUser) {
        self.nick = dtosUser.nick
        self.realName = dtosUser.realName
        self.host = dtosUser.host
    }
    
    // Convert to DtosUser instance
    func toDtosUser() -> DtosUser {
        let dtosUser = DtosUser()
        dtosUser.nick = self.nick
        dtosUser.realName = self.realName
        dtosUser.host = self.host
        return dtosUser
    }
}
