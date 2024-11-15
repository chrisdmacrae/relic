//
//  ConnectView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import SwiftUI

struct ConnectView: View {
    var onConnect: (String, Int, String, String, String?, String?) -> Void
    var onCancel: () -> Void
    
    @EnvironmentObject var serverState: ServerState
    @State private var hostname: String = "irc."
    @State private var port: Int = 6697
    @State private var nickname: String = ""
    @State private var realname: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var usernameIsNickname: Bool = true
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Spacer()
                
                Text("Connect to an IRC server")
                    .fontWeight(.bold)
                    .font(.title)
                
                HStack(spacing: 6) {
                    VStack(alignment: .leading) {
                        Text("Hostname")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        TextField("Hostname", text: $hostname)
                            .textFieldStyle(InputStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Port")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        TextField("Port", value: $port, format: .number)
                            .textFieldStyle(InputStyle())
                            .frame(width: 64)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Nickname")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    TextField("Display name", text: $nickname)
                        .textFieldStyle(InputStyle())
                }
                
                VStack(alignment: .leading) {
                    Text("Real name")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    TextField("Real name", text: $realname)
                        .textFieldStyle(InputStyle())
                }
                            
                    VStack(alignment: .leading) {
                        Text("Username")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        HStack(alignment: .center) {

                        TextField("Username", text: $username)
                            .textFieldStyle(InputStyle())
                            .disabled(usernameIsNickname)
                    
                        Toggle(isOn: $usernameIsNickname) {
                            Text("Same as nickname")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                        .onChange(of: usernameIsNickname) { newValue in
                            if newValue {
                                username = nickname
                            }
                        }
                        .onChange(of: nickname) { newValue in
                            if usernameIsNickname {
                                username = newValue
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    Text("Password (optional)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    SecureField("Password", text: $password)
                        .textFieldStyle(InputStyle())
                }
                
                Spacer()
            }
                .frame(maxWidth: 520)
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(.gray.opacity(0.25))
                HStack {
                    Button(action: onCancel) {
                        Text("Cancel")
                    }
                    .buttonStyle(ConnectButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        onConnect(hostname, port, nickname, realname, username != "" ? username : nil, password != "" ? password : nil)
                    }) {
                        Text("Connect")
                    }
                    .buttonStyle(ConnectButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .onAppear() {                
                if (serverState.selectedServer != nil) {
                    let server = serverState.selectedServer!
                    hostname = server.hostname
                    port = server.port
                    nickname = server.nickname
                    realname = server.realname
                    
                    if server.username == "" {
                        usernameIsNickname = true
                        username = server.nickname
                    } else if (server.username != nil) {
                        username = server.username!
                    }
                    
                    if (server.password != nil && server.password != "") {
                        password = server.password!
                    }
                }
            }
        }
}

struct InputStyle : TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            .padding(8)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
    }
}

#Preview {
    ConnectView(onConnect: { _, _, _, _, _, _  in }, onCancel: { })
}
