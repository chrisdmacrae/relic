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
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
            // Message bubble with tail
            HStack {
                if isCurrentUser {
                    Spacer()
                }
                
                Text(message.text.replacingOccurrences(of: "\\n", with: "\n"))
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
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                if isCurrentUser {
                    Spacer()
                }
                
                // User's name
                Text(message.nick)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                
                // Timestamp at the bottom
                Text(Date(timeIntervalSince1970: TimeInterval(message.timestamp) / 1000), format: .dateTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                if !isCurrentUser {
                    Spacer()
                }
            }
            
            HStack(spacing: 8) {
                ForEach(extractImageURLs(from: message.text), id: \.self) { url in
                    if (url.path().hasSuffix(".gif")) {
                        GifImageView(url: url)
                            .cornerRadius(10)
                            .frame(maxWidth: 200) // Adjust the max width as needed
                            .aspectRatio(contentMode: .fit)
                    } else {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 200) // Adjust the max width as needed
                                    .cornerRadius(10)
                            case .failure:
                                Text("Failed to load image")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                
                ForEach(extactYoutubeURLs(from: message.text), id: \.self) { url in
                    YoutubeVideoView(videoUrl: url.absoluteString)
                        .cornerRadius(10)
                        .frame(width: 480, height: 480 * 9 / 16) // Set width to 480 and calculate height for 16:9 ratio
                        .clipped()
                        .aspectRatio(16/9, contentMode: .fit)
                }
            }
            .padding(.top, 8)
            .frame(alignment: isCurrentUser ? .topTrailing : .topLeading)
        }
        .padding(isCurrentUser ? .trailing : .leading, 10)
        .frame(minHeight: 0)
    }
    
    // Extract URLs with image extensions
    func extractImageURLs(from text: String) -> [URL] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) ?? []
        return matches.compactMap { match in
            guard let url = match.url else { return nil }
            let pathExtension = url.pathExtension.lowercased()
            return ["jpg", "jpeg", "png", "gif"].contains(pathExtension) ? url : nil
        }
    }
    
    func extactYoutubeURLs(from text: String) -> [URL] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) ?? []
        return matches.compactMap { match in
            guard let url = match.url else { return nil }
            let host = url.host?.lowercased()
            return host?.contains("youtube.com") == true ? url : nil
        }
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
