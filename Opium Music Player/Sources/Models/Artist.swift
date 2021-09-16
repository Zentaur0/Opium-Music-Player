//
//  Artist.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 04.09.2021.
//

import Foundation

// MARK: - Artist

struct Artist: Decodable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
}

// MARK: - ArtistAlbums

struct ArtistAlbums: Decodable {
    let items: [Album]
}

// MARK: - ArtistTracks

struct ArtistTracks: Decodable {
    let tracks: [AudioTrack]
}
