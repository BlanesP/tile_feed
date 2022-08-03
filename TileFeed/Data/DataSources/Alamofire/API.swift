//
//  API.swift
//  TileFeed
//
//  Created by Pau Blanes on 28/7/22.
//

//NOTE: In a real app this file would be generated automatically

struct TileRequest {
    struct Response {
        struct Tiles: Decodable {
            let tiles: [Tile]
        }

        struct Tile: Decodable {
            let name: String
            let headline: String
            let subline: String?
            let data: String?
            let score: Int
        }
    }
}

