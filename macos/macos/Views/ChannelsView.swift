//
//  ChannelView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import SwiftUI

struct ChannelsView: View {
    @EnvironmentObject var ircContext: IrcContext
    @EnvironmentObject var appState: AppState
    @State private var filter = ""
    @State private var filteredChannels = [String]()
    @State private var showManualChannel = false
    @State private var manualChannel = ""
    
    // UI logic
    @State private var pinnedChannelsSize = CGSize.zero
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack {
                    Text("Pinned Channels")
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                
                if appState.pinnedChannels.count > 0 {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(appState.pinnedChannels, id: \.self) { channel in
                                Button(action: {
                                    appState.selectedChannel = channel
                                }) {
                                    HStack {
                                        Text(channel)
                                        Spacer()
                                        Button(action: {
                                            appState.unpinChannel(channel: channel)
                                        }) {
                                            Text("-")
                                        }
                                    }
                                }
                                .buttonStyle(ConnectButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            pinnedChannelsSize = geo.size
                                        }
                                    }
                            }                        )
                    }
                    .frame(minHeight: 0, maxHeight: pinnedChannelsSize.height) // Ensures the first ScrollView takes only the required space
                } else {
                    VStack(spacing: 4) {
                        Text("No pinned channels")
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        Text("+ a channel to pin it")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                }
            }
            
            Spacer()
            
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    HStack {
                        Text("All Channels")
                            .fontWeight(.bold)
                        Spacer()
                        Button("+") {
                            showManualChannel.toggle()
                        }
                        .popover(isPresented: $showManualChannel) {
                            VStack(spacing: 12) {
                                Text("Join Channel")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                TextField("Channel", text: $manualChannel)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onKeyPress(.return, action: {
                                        appState.joinChannel(channel: manualChannel)
                                        showManualChannel.toggle()
                                        
                                        return .handled
                                    })
                                Button("Join") {
                                    appState.joinChannel(channel: manualChannel)
                                    showManualChannel.toggle()
                                }
                            }
                            .frame(width: 200)
                            .padding()
                        }
                    }
                    
                    TextField("Filter", text: $filter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: appState.channels) {
                            filteredChannels = appState.channels ?? []
                        }
                        .onChange(of: filter) { value in
                            if value.isEmpty {
                                filteredChannels = appState.channels ?? []
                            } else if (appState.channels != nil) {
                                filteredChannels = appState.channels!.filter { $0.contains(value) }
                            }
                        }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .background(Color.gray.opacity(0.15))
                
                ScrollView {
                    if (appState.isLoadingChannels) {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.5)
                                .padding()
                            
                            Text("Loading public channels")
                                .font(.callout)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                appState.loadChannels()
                            }) {
                                Text("Not loaded yet? Try again")
                            }
                                .font(.caption)
                                .buttonStyle(LinkButtonStyle())
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                        
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredChannels, id: \.self) { channel in
                                Button(action: {
                                    appState.selectedChannel = channel
                                }) {
                                    HStack {
                                        Text(channel)
                                        Spacer()
                                        Button(action: {
                                            appState.pinChannel(channel: channel)
                                        }) {
                                            Text("+")
                                        }
                                    }
                                }
                                .buttonStyle(ConnectButtonStyle())
                            }
                        }
                        .padding(.vertical)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ChannelsView()
}
