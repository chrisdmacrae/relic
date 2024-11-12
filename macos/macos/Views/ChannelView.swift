//
//  ChannelView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-11.
//

import SwiftUI
import Core

struct ChannelView: View {
    var name: String
    
    @EnvironmentObject private var serverState: ServerState
    @State private var channel: Channel?
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Divider()
                .padding(0)
                .frame(height: 1)
                .background(.gray.opacity(0.25))
            
            if (channel != nil) {
                VStack(alignment: .leading) {
                    if (channel!.topic != "") {
                        VStack(alignment: .leading) {
                            Text(channel!.topic)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                            
                            Divider()
                                .padding(0)
                                .frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .background(.gray.opacity(0.25))
                        }
                        .padding()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Users: \(channel!.nicks.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ForEach(channel!.nicks, id: \.self) { nick in
                            Text(nick)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            } else if (isLoading) {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                Spacer()
            } else {
                Spacer()
                Text("Error loading channel")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
        }
        .onAppear() {
            DispatchQueue.global(qos: .background).async {
                channel = serverState.getChannel(channel: name)
                isLoading = false
            }
        }
        .onReceive(serverState.$selectedChannel) { _ in
            DispatchQueue.global(qos: .background).async {
                channel = serverState.getChannel(channel: name)
                isLoading = false
            }
        }
    }
}

#Preview {
    ChannelView(name: "test")
}
