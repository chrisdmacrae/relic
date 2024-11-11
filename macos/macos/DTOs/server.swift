//
//  server.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import Core

// Wrapper for DtosServer
struct Server: Codable {
    var hostname: String
    var port: Int
    var nickname: String
    var realname: String
    var password: String?

    // Initialize from DtosServer instance
    init(from dtosServer: DtosServer) {
        self.hostname = dtosServer.hostname
        self.port = Int(dtosServer.port)
        self.nickname = dtosServer.nickname
        self.realname = dtosServer.realname
        self.password = dtosServer.password
    }
    
    // Convert to DtosServer instance
    func toDtosServer() -> DtosServer {
        let dtosServer = DtosServer()
        dtosServer.hostname = self.hostname
        dtosServer.port = Int(self.port)
        dtosServer.nickname = self.nickname
        dtosServer.realname = self.realname
        if (self.password != nil) {
            dtosServer.password = self.password!
        }
        return dtosServer
    }
}
