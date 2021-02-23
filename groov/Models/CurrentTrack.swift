//
//  CurrentTrack.swift
//  groov
//
//  Created by Alice Wu on 2/22/21.
//

import Foundation

struct CurrentTrack: Codable {
    let item: CurrentTrackItem
}

struct CurrentTrackArtist: Codable {
    let name: String
}

struct CurrentTrackImage: Codable {
    let url: String
}

struct CurrentTrackAlbum: Codable {
    let artists: [CurrentTrackArtist]
    let images: [CurrentTrackImage]
}

struct CurrentTrackItem: Codable {
    let album: CurrentTrackAlbum
    let name: String
    let preview_url: String
}
