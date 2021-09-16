//
//  Search.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 05.09.2021.
//

import Foundation

// MARK: - SearchResultsResponse

struct SearchResultsResponse: Decodable {
    let albums: SearchAlbumsResponse
    let artists: SearchArtistsResponse
    let playlists: SearchPlaylistsResponse
    let tracks: SearchTracksResponse
}

// MARK: - SearchAlbumsResponse

struct SearchAlbumsResponse: Decodable {
    let items: [Album]
}

// MARK: - SearchArtistsResponse

struct SearchArtistsResponse: Decodable {
    let items: [Artist]
}

// MARK: - SearchPlaylistsResponse

struct SearchPlaylistsResponse: Decodable {
    let items: [Playlist]
}

// MARK: - SearchTracksResponse

struct SearchTracksResponse: Decodable {
    let items: [AudioTrack]
}

// MARK: - SearchResult

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case playlist(model: Playlist)
    case track(model: AudioTrack)
}
