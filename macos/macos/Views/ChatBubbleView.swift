//
//  ChatBubbleView.swift
//  macos
//
//  Created by Christopher Macrae on 2024-11-10.
//

import SwiftUI
import Core

struct ChatBubbleView: View {
    let message: Core.ModelsMessage
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
            // Message bubble with tail
            HStack {
                if isCurrentUser {
                    Spacer()
                }
                
                Text(message.text)
                    .padding()
                    .background(
                        ChatBubbleShape(isCurrentUser: isCurrentUser)
                            .fill(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .frame(alignment: .leading)
                    .padding(isCurrentUser ? .leading : .trailing, 0)
                
                if !isCurrentUser {
                    Spacer()
                }
            }
            
            VStack(spacing: 2) {
                if isCurrentUser {
                    Spacer()
                }
                
                // User's name
                Text(message.nick)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(isCurrentUser ? .leading : .trailing, 0)
                
                // Timestamp at the bottom
                Text(Date(timeIntervalSince1970: TimeInterval(message.timestamp) / 1000), format: .dateTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(isCurrentUser ? .leading : .trailing, 24)
                
                if !isCurrentUser {
                    Spacer()
                }
            }
            .frame(minHeight: 0)
        }
        .padding(isCurrentUser ? .trailing : .leading, 10)
    }
}

struct ChatBubbleShape: Shape {
    var isCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        let bezierPath = NSBezierPath()
        if !isCurrentUser {
            bezierPath.move(to: NSPoint(x: 20, y: height))
            bezierPath.line(to: NSPoint(x: width - 15, y: height))
            bezierPath.curve(to: NSPoint(x: width, y: height - 15), controlPoint1: NSPoint(x: width - 8, y: height), controlPoint2: NSPoint(x: width, y: height - 8))
            bezierPath.line(to: NSPoint(x: width, y: 15))
            bezierPath.curve(to: NSPoint(x: width - 15, y: 0), controlPoint1: NSPoint(x: width, y: 8), controlPoint2: NSPoint(x: width - 8, y: 0))
            bezierPath.line(to: NSPoint(x: 20, y: 0))
            bezierPath.curve(to: NSPoint(x: 5, y: 15), controlPoint1: NSPoint(x: 12, y: 0), controlPoint2: NSPoint(x: 5, y: 8))
            bezierPath.line(to: NSPoint(x: 5, y: height - 10))
            bezierPath.curve(to: NSPoint(x: 0, y: height), controlPoint1: NSPoint(x: 5, y: height - 1), controlPoint2: NSPoint(x: 0, y: height))
            bezierPath.line(to: NSPoint(x: -1, y: height))
            bezierPath.curve(to: NSPoint(x: 12, y: height - 4), controlPoint1: NSPoint(x: 4, y: height + 1), controlPoint2: NSPoint(x: 8, y: height - 1))
            bezierPath.curve(to: NSPoint(x: 20, y: height), controlPoint1: NSPoint(x: 15, y: height), controlPoint2: NSPoint(x: 20, y: height))
        } else {
            bezierPath.move(to: NSPoint(x: width - 20, y: height))
            bezierPath.line(to: NSPoint(x: 15, y: height))
            bezierPath.curve(to: NSPoint(x: 0, y: height - 15), controlPoint1: NSPoint(x: 8, y: height), controlPoint2: NSPoint(x: 0, y: height - 8))
            bezierPath.line(to: NSPoint(x: 0, y: 15))
            bezierPath.curve(to: NSPoint(x: 15, y: 0), controlPoint1: NSPoint(x: 0, y: 8), controlPoint2: NSPoint(x: 8, y: 0))
            bezierPath.line(to: NSPoint(x: width - 20, y: 0))
            bezierPath.curve(to: NSPoint(x: width - 5, y: 15), controlPoint1: NSPoint(x: width - 12, y: 0), controlPoint2: NSPoint(x: width - 5, y: 8))
            bezierPath.line(to: NSPoint(x: width - 5, y: height - 12))
            bezierPath.curve(to: NSPoint(x: width, y: height), controlPoint1: NSPoint(x: width - 5, y: height - 1), controlPoint2: NSPoint(x: width, y: height))
            bezierPath.line(to: NSPoint(x: width + 1, y: height))
            bezierPath.curve(to: NSPoint(x: width - 12, y: height - 4), controlPoint1: NSPoint(x: width - 4, y: height + 1), controlPoint2: NSPoint(x: width - 8, y: height - 1))
            bezierPath.curve(to: NSPoint(x: width - 20, y: height), controlPoint1: NSPoint(x: width - 15, y: height), controlPoint2: NSPoint(x: width - 20, y: height))
        }
        return Path(bezierPath.cgPath)
    }
}

#Preview {
    ChatBubbleView(message: Core.ModelsMessage(), isCurrentUser: true)
}
