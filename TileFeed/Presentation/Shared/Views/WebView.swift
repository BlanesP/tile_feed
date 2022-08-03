//
//  WebView.swift
//  TileFeed
//
//  Created by Pau Blanes on 31/7/22.
//

import SwiftUI

private extension LocalizedStringKey {
    static var couldntLoadUrl: Self { "Couldn't load url..." }
}

//MARK: - Main View

struct WebView: View {
    let url: URL

    @State private var state: WebViewRepresentable.ViewState = .initial

    var body: some View {
        ZStack {
            WebViewRepresentable(url: url, viewState: $state)

            if state == .loading {
                ProgressView()
            } else if state == .error {
                Text(.couldntLoadUrl)
                    .font(.title3)
            }
        }
        .defaultShadow()
    }
}

//MARK: - Previews

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://www.apple.com")!)
    }
}
