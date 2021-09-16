//
//  Fileca.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 03.09.2021.
//

import Foundation

// MARK: - CategoriesResponse

struct CategoriesResponse: Decodable {
    let categories: Categories
}

// MARK: - Categories

struct Categories: Decodable {
    let items: [Category]?
}

// MARK: - Category

struct Category: Decodable {
    let id: String
    let name: String
}
