//
//  View+Utils.swift
//  TileFeed
//
//  Created by Pau Blanes on 31/7/22.
//

import SwiftUI

private extension Color {
    static var shadowColor: Self { .black.opacity(0.2) }
}

extension View {
    func defaultShadow() -> some View {
        self
            .shadow(color: .shadowColor, radius: .sizeSmall)
    }
}
