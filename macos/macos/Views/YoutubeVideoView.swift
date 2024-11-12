import SwiftUI
import WebKit

struct YoutubeVideoView: NSViewRepresentable {
    let videoID: String?
    
    init(videoID: String) {
        self.videoID = videoID
    }
    
    init(videoUrl: String) {
        self.videoID = YoutubeVideoView.parseYouTubeVideoID(from: videoUrl)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Set up WebView properties
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36"
        webView.allowsBackForwardNavigationGestures = false
        webView.configuration.mediaTypesRequiringUserActionForPlayback = .video
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator // Set the UI delegate for fullscreen support
        
        if let videoID = videoID {
            loadYouTubeVideo(webView, videoId: videoID)
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    private func loadYouTubeVideo(_ webView: WKWebView, videoId: String) {
        let embedHTML = """
        <!DOCTYPE html>
        <html style="width: 100%; height: 100%;">
        <body style="width: 100%; height: 100%; margin: 0; padding: 0; overflow: hidden;">
        <iframe width="100%" height="100%" src="https://www.youtube.com/embed/\(videoId)?playsinline=1" frameborder="0" allow="autoplay; encrypted-media; fullscreen" allowfullscreen style="width: 100%; height: 100%;"></iframe>
        </body>
        </html>
        """
        
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    static func parseYouTubeVideoID(from urlString: String) -> String? {
        let patterns = [
            "https?://(?:www\\.)?youtube\\.com/watch\\?v=([^&]+)",       // Standard YouTube URL
            "https?://(?:www\\.)?youtube\\.com/v/([^&/]+)",             // Embedded YouTube URL
            "https?://(?:www\\.)?youtube\\.com/embed/([^&/]+)",         // Embed URL
            "https?://youtu\\.be/([^&?/]+)"                             // Shortened youtu.be URL
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                if let match = regex.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count)) {
                    if let range = Range(match.range(at: 1), in: urlString) {
                        return String(urlString[range])
                    }
                }
            }
        }
        
        return nil
    }
    
    // Coordinator class to handle link opening in the system browser and fullscreen requests
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel) // Cancel the request to open in web view
            } else {
                decisionHandler(.allow) // Allow other types of requests
            }
        }
        
        // Handle fullscreen requests
        func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
            completionHandler(nil)
        }
        
        func webView(_ webView: WKWebView, didClose navigationAction: WKNavigationAction) {
            webView.exitFullScreenMode(options: nil)
        }
    }
}

    #Preview {
        YoutubeVideoView(videoUrl: "https://www.youtube.com/watch?v=8jPQjjsBbIc")
            .frame(width: 480, height: 480 * 9 / 16) // Set 16:9 aspect ratio frame with width 480
    }
