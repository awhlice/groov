//
//  RankedTrack.swift
//  groov
//
//  Created by Alice Wu on 2/22/21.
//

import Foundation

struct RankedTrack: Codable {
    let items: [RankedTrackItem]
}

struct RankedTrackArtist: Codable {
    let name: String
}

struct RankedTrackImage: Codable {
    let url: String
}

struct RankedTrackAlbum: Codable {
    let artists: [RankedTrackArtist]
    let images: [RankedTrackImage]
}

struct RankedTrackItem: Codable {
    let album: RankedTrackAlbum
    let name: String
    let preview_url: String
}
