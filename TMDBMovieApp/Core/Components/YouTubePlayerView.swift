//
//  YouTubePlayerView.swift
//  TMDBMovieApp
//
//  A SwiftUI wrapper for WKWebView to play YouTube videos.
//

import SwiftUI
import WebKit

/// A view that embeds a YouTube video using WKWebView.
struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true // Crucial for iOS playback
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false // Prevents white flash before video loads
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

#Preview {
    YouTubePlayerView(videoID: "dQw4w9WgXcQ") // Rickroll for preview
        .frame(height: 250)
}
