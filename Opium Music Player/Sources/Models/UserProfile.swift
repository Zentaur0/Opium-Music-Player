//
//  UserProfile.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 05.09.2021.
//

import Foundation

// MARK: - UserProfile

struct UserProfile: Decodable {
    let country: String
    let display_name: String
    let email: String
    let id: String
    let product: String
    let images: [APIImage]
}
