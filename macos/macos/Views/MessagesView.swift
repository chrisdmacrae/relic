//
//  MessagesView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var serverState: ServerState
    @State private var message = ""
    @State private var hasNewMessages = false
    
    var body: some View {
        VStack {
            if (serverState.isLoadingSelectedChannel) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if (serverState.selectedChannel != nil) {
                VStack(spacing: 0) {
                    Divider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .background(.gray.opacity(0.25))
                    
                    ZStack {
                        GeometryReader { scrollViewGeo in
                            ScrollViewReader { proxy in
                                ZStack {
                                    ScrollView {
                                        LazyVStack(spacing: 16) {
                                            ForEach(serverState.messages, id: \.self) { message in
                                                ChatBubbleView(message: message, isCurrentUser: message.nick == serverState.selectedServer?.nickname)
                                            }
                                        }
                                        .padding(.top, 16)
                                        .padding(.bottom, 120)
                                        
                                        VStack{}
                                            .id(-1)
                                            .background(
                                                GeometryReader { geo in
                                                    Color.clear                                                    .onChange(of: serverState.messages) { _ in
                                                        let visible = checkIfVisible(geo: geo, scrollViewGeo: scrollViewGeo, id: -1)
                                                        
                                                        hasNewMessages = !visible
                                                    }
                                                }
                                            )
                                    }
                                    .onReceive(serverState.$messages) { messages in
                                        if let lastMessage = messages.last {
                                            if lastMessage.nick == serverState.selectedServer?.nickname {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    proxy.scrollTo(-1, anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                    
                                    VStack {
                                        if hasNewMessages {
                                            HStack {
                                                Button("New messages. View now") {
                                                    withAnimation {
                                                        proxy.scrollTo(-1, anchor: .bottom)
                                                    }
                                                    
                                                    hasNewMessages = false
                                                }
                                                .buttonStyle(LinkButtonStyle())
                                                .padding()
                                            }
                                            .background(.thinMaterial)
                                            .shadow(radius: 4)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .ignoresSafeArea(.container)
                                    .padding(.bottom, 120)
                                }
                            }
                        }
                        
                        VStack {
                            Spacer()
                            
                            VStack {
                                Divider()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 1)
                                    .background(.gray.opacity(0.01))
                                MessagesInputView(text: $message, onSubmit: sendMessage)
                            }
                            .ignoresSafeArea(.container)
                            .background(.thinMaterial)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea(.container)
                    }
                }
                .toolbar {
                    ToolbarItemGroup {
                        HStack {
                            Text("\(serverState.selectedChannel!)")
                                .fontWeight(.bold)
                            Button(action: {
                                serverState.pinChannel(channel: serverState.selectedChannel!)
                            }) {
                                Text("+")
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            } else {
                Text("Select a channel")
                    .font(.title)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private func sendMessage() {
        if (serverState.selectedChannel == nil) {
            return
        }
        
        serverState.sendMessage(serverState.selectedChannel!, message: message.replacingOccurrences(of: "\n", with: "\\n"))
        
        message = ""
    }
    
    private func checkIfVisible(geo: GeometryProxy, scrollViewGeo: GeometryProxy, id: AnyHashable) -> Bool {
            let viewFrame = geo.frame(in: .global)
            let scrollViewFrame = scrollViewGeo.frame(in: .global)
            
            return scrollViewFrame.intersects(viewFrame)
        }
}

#Preview {
    MessagesView()
}
