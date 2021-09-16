//
//  AuthentificationResponse.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 01.09.2021.
//

import UIKit

// MARK: - AuthentificationResponse

final class AuthentificationResponse: Codable {
    
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
    
}
