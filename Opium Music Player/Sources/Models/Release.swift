//
//  Release.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 03.09.2021.
//

import Foundation

// MARK: - NewReleaseResponse

struct NewReleaseResponse: Decodable {
    let albums: AlbumsResponse?
}
