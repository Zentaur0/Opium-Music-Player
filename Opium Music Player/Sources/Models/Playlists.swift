//
//  Playlists.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 03.09.2021.
//

import Foundation

// MARK: - PlaylistResponse

struct PlaylistResponse: Decodable {
    let playlists: Playlists?
}

// MARK: - Playlists

struct Playlists: Decodable {
    let items: [Playlist]?
}

// MARK: - Playlist

struct Playlist: Decodable {
    let id: String
    let name: String
    let images: [APIImage]
    let description: String
}

// MARK: - PlaylistDetailsResponse

struct PlaylistDetailsResponse: Decodable {
    let description: String
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlaylistTracksResponse?
}

// MARK: - PlaylistTracksResponse

struct PlaylistTracksResponse: Decodable {
    let items: [PlaylistItem]?
}

// MARK: - PlaylistItem

struct PlaylistItem: Decodable {
    let track: AudioTrack?
}
