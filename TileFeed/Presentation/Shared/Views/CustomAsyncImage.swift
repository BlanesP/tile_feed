//
//  CustomAsyncImage.swift
//  TileFeed
//
//  Created by Pau Blanes on 1/8/22.
//

import SwiftUI

private extension CGFloat {
    static var placeholderSize: Self { 48 }
}

//MARK: - Main View

struct CustomAsyncImage: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(
            url: url,
            content: { image in
                image.resizable()
                     .aspectRatio(contentMode: .fit)
            },
            placeholder: {
                HStack(alignment: .center) {
                    Spacer()

                    Image.imagePlaceholder
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: .placeholderSize)
                        .foregroundColor(.gray)

                    Spacer()
                }

            }
        )
    }
}
