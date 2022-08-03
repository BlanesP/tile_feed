//
//  TileListView.swift
//  TileFeed
//
//  Created by Pau Blanes on 28/7/22.
//

import AVKit
import SwiftUI

private extension CGFloat {
    static var maxImageTileHeight: Self { 300 }
    static var loaderSize: Self { 250 }
    static var progressScale: Self { 1.5 }
}

private extension LocalizedStringKey {
    static var website: Self { "Website" }
    static var welcomeBack: Self { "Welcome back!" }
    static var nothingToSee: Self { "Nothing to see here..." }
    static var errorMsg: Self { "Ups! Something went wrong." }
    static var ok: Self { "Ok" }

    static func items(_ count: Int) -> Self {
        "\(count) items"
    }
}

//MARK: - Main View

struct TileListView: View {

    @ObservedObject var viewModel: TileListViewModel

    @State private var showLoader = false

    var body: some View {
        NavigationView {
            VStack {
                if showLoader {
                    ProgressView()
                        .scaleEffect(.progressScale)
                        .padding(.top, .sizeLargeExtra)
                } else if !viewModel.tileList.isEmpty {
                    contentView
                } else {
                    Text(.nothingToSee)
                        .font(.title2)
                        .padding(.top, .sizeLargeExtra)
                }

                Spacer()
            }
            .navigationTitle(.welcomeBack)
        }
        .onReceive(viewModel.output, perform: output)
        .onAppear { [weak viewModel] in
            viewModel?.input(.fetchTiles)
        }
    }

    var contentView: some View {
        List(viewModel.tileList, id: \.id) { tile in
            TileRowView(tile: tile)
                .listRowSeparator(.hidden)
                .listRowInsets(
                    EdgeInsets(
                        top: .sizeNormal,
                        leading: .sizeLarge,
                        bottom: .sizeNormal,
                        trailing: .sizeLarge
                    )
                )
                .background(
                    NavigationLink(
                        destination: ViewFactory.tileDetailView(tile: tile, onTileChangedd: viewModel.onTileChanged),
                        label: { EmptyView() }
                    )
                    .opacity(0)
                )
        }
        .listStyle(.plain)
    }

    func output(_ value: TileListViewModel.ViewOutput) {
        showLoader = (value == .loading)
    }
}

//MARK: - AdditionalViews

struct TileRowView: View {
    let tile: Tile

    var body: some View {
        VStack(alignment: .leading, spacing: .sizeLarge) {
            if let title = tile.title {
                Text(title)
                    .font(.headline)
                    .bold()
                    .padding(.horizontal, .sizeLarge)
            }

            if let urlTile = tile as? URLTile {
                urlTile.contentView
                    .frame(maxWidth: .infinity)

            } else if let shoppingTile = tile as? ShoppingTile {
                HStack(alignment: .center, spacing: .sizeSmall) {
                    Image.cart

                    Text(.items(shoppingTile.cartItems.count))

                    Spacer()
                }
                .padding(.horizontal, .sizeLarge)
            }

            if let subtitle = tile.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .padding(.horizontal, .sizeLarge)
            }
        }
        .padding(.vertical, .sizeLarge)
        .background(Color.white)
        .cornerRadius(.sizeNormal)
        .defaultShadow()
    }
}

// MARK: - Utils

private extension URLTile {
    @ViewBuilder var contentView: some View {
        switch self.type {
        case .image:
            CustomAsyncImage(url: url)
                .frame(maxHeight: .maxImageTileHeight)

        case .video:
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fit)

        case .website:
            Text(.website)
                .font(.callout)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .sizeLarge)
        }
    }
}

//MARK: - Previews

struct TileListView_Previews: PreviewProvider {
    static var previews: some View {
        ViewFactory.homeView
    }
}
