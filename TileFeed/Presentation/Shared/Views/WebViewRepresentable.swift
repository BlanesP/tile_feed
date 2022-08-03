//
//  WebViewRepresentable.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    enum ViewState {
        case initial, loading, ready, error
    }

    var url: URL
    @Binding var viewState: ViewState

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if viewState == .initial {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension WebViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable

        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.parent.viewState = .loading
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.parent.viewState = .error
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.parent.viewState = .error
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.viewState = .ready
        }
    }
}
