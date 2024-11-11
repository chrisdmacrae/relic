//
//  MessagesView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-09.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var ircContext: IrcContext
    @EnvironmentObject private var appState: AppState
    @State private var message = ""
    
    @Binding var navigationSplitViewVisibility: NavigationSplitViewVisibility
    
    init(navigationSplitViewVisibility: Binding<NavigationSplitViewVisibility>) {
        _navigationSplitViewVisibility = navigationSplitViewVisibility
    }
    
    var body: some View {
        VStack {
            if (appState.isLoadingSelectedChannel) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if (appState.selectedChannel != nil) {
                VStack(spacing: 0) {
                    HStack {
                        Text("\(appState.selectedChannel!)")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.leading, navigationSplitViewVisibility != .doubleColumn ? 32 : 8)
                    .padding(.vertical, 8)
                    
                    Divider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .background(.gray.opacity(0.25))
                    
                    Spacer()
                    
                    VStack {
                        ForEach(appState.messages, id: \.self) { message in
                            ChatBubbleView(message: message, isCurrentUser: message.nick == appState.selectedServer?.nickname)
                        }
                    }
                    .padding(.bottom, 8)
                                        
                    Divider()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .background(.gray.opacity(0.25))
                    HStack {
                        TextField("Message", text: $message)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                sendMessage()
                            }
                        Button("Send") {
                            sendMessage()
                        }
                        .keyboardShortcut(.return)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .ignoresSafeArea(.container)
            } else {
                Text("Select a channel")
                    .font(.title)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    func sendMessage() {
        if (appState.selectedChannel == nil) {
            return
        }
        
        appState.sendMessage(appState.selectedChannel!, message: message)
        
        message = ""
    }
}

#Preview {
    MessagesView(navigationSplitViewVisibility: .constant(.automatic))
}
