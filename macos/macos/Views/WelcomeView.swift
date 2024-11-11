//
//  ConnectView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    var onConnect: () -> Void
        
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image("placeholderIcon")
                        .resizable()           // Make the image resizable
                        .scaledToFit()          // Scale the image to fit within its container
                        .frame(width: 200, height: 200) // Set the dimensions of the image
                    VStack {
                        Text("relirc")
                            .fontWeight(.bold)
                            .font(.title)
                        Text("Version 0.1.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(minWidth: 420, maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 8)
                .background(.white.opacity(0.5))
                
                if (appState.recentServers.count > 0) {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Recent servers")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(appState.recentServers, id: \.hostname) { server in
                                Button(action: {
                                    appState.selectedServer = server
                                    onConnect()
                                }) {
                                    HStack {
                                        Text(server.nickname)
                                        Spacer()
                                        Text(server.hostname)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                }
                                .buttonStyle(ConnectButtonStyle())
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            VStack(spacing: 0) {
                Divider()
                    .padding(0)
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(.gray.opacity(0.25))
                
                VStack {
                    Button(action: {
                        appState.selectedServer = nil
                        onConnect()
                    }) {
                        Text("Connect to an IRC server")
                    }
                    .buttonStyle(ConnectButtonStyle())
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
            }
        }
    }
}

// Generate a button style
struct ConnectButtonStyle: ButtonStyle {    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(configuration.isPressed ? 0.25 : 0.20))
            .cornerRadius(8)
    }
}

#Preview {
    WelcomeView(onConnect: { })
}
