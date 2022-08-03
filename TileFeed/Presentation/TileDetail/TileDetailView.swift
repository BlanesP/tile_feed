//
//  TileDetailView.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import AVKit
import SwiftUI

private extension LocalizedStringKey {
    static var detail: Self { "Detail" }
    static var errorMsg: Self { "Ups! Something went wrong while adding a new item to cart :(" }
    static var ok: Self { "Ok" }
    static var shoppingPlaceholder: Self { "Type a new item to add..." }
}

//MARK: - Main View

struct TileDetailView: View {
    @ObservedObject var viewModel: TileDetailViewModel

    @State private var showError = false

    var body: some View {
        VStack(alignment: .leading, spacing: .sizeLarge) {
            Text(viewModel.tile.title ?? LocalizedStringKey.detail.toString())
                .font(.title)
                .bold()

            if let subtitle = viewModel.tile.subtitle {
                Text(subtitle)
                    .font(.title3)
            }

            if let urlTile = viewModel.tile as? URLTile {
                urlTile.contentView
                    .padding(.top, .sizeLarge)
            } else if let shoppingTile = viewModel.tile as? ShoppingTile {
                ShoppingView(tile: shoppingTile)
                    .environmentObject(viewModel)
                    .padding(.top, .sizeLarge)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, .sizeLarge)
        .onReceive(viewModel.output, perform: output)
        .alert(.errorMsg, isPresented: $showError) {
            Button(LocalizedStringKey.ok.toString().uppercased(), role: .cancel) { }
        }
    }

    func output(_ value: TileDetailViewModel.ViewOutput) {
        switch value {
        case .error:
            showError = true
        }
    }
}

//MARK: - Additional Views

struct ShoppingView: View {
    @EnvironmentObject var viewModel: TileDetailViewModel

    let tile: ShoppingTile

    @State private var shoppingText = ""

    var body: some View {
        VStack(spacing: .sizeNormal) {
            TextField(
                .shoppingPlaceholder,
                text: $shoppingText,
                onCommit: { [weak viewModel] in
                    viewModel?.input(.addCartItem(shoppingText))
                    shoppingText = ""
                })
                .padding(.sizeNormal)
                .overlay(
                    RoundedRectangle(cornerRadius: .sizeLarge)
                        .strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0))
                )

            if !tile.cartItems.isEmpty {
                List(tile.cartItems.indices, id: \.self) { index in
                    Text(tile.cartItems[index])
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - Utils

private extension URLTile {
    @ViewBuilder var contentView: some View {
        switch self.type {
        case .image:
            CustomAsyncImage(url: url)
            
        case .video:
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fit)

        case .website:
            WebView(url: url)
                .frame(maxWidth: .infinity)
        }
    }
}

//MARK: - Previews

struct TileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ViewFactory.tileDetailView(
            tile: URLTile(
                id: UUID(),
                title: "Test title",
                subtitle: "Test subtitle",
                ranking: 0,
                type: .website,
                url: URL(string: "https://www.apple.com")!
            )
        )
    }
}
