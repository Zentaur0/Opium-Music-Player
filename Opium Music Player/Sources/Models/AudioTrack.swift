//
//  AudioTrack.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.09.2021.
//

import Foundation

// MARK: - TracksResponse

struct TracksResponse: Decodable {
    let items: [AudioTrack]?
}

// MARK: - AudioTrack

struct AudioTrack: Decodable {
    var album: Album?
    let artists: [Artist]?
    let id: String
    let name: String
    let preview_url: String?
    let external_urls: ExternalURL?
}

// MARK: - ExternalURL

struct ExternalURL: Decodable {
    let spotify: String?
}

// MARK: - AudioTrack Equatable

extension AudioTrack: Equatable {
    
    static func == (lhs: AudioTrack, rhs: AudioTrack) -> Bool {
        return lhs.id == rhs.id
    }
    
}
