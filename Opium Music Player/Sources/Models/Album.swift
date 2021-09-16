//
//  Album.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 12.09.2021.
//

import Foundation

// MARK: - AlbumsResponse

struct AlbumsResponse: Decodable {
    let items: [Album]?
}

// MARK: - AlbumDetailsResponse

struct AlbumDetailsResponse: Decodable {
    let album_type: String?
    let artists: [Artist]
    let id: String
    let images: [APIImage]
    let label: String
    let name: String
    let tracks: TracksResponse?
}

// MARK: - Album Equatable

struct Album: Decodable {
    let id: String
    let album_type: String?
    var images: [APIImage]?
    let name: String
    let release_date: String
    let artists: [Artist]
}

// MARK: - Album Equatable

extension Album: Equatable {
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
}
