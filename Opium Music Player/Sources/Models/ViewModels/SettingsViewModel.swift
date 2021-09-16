//
//  SettingsViewModel.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 12.09.2021.
//

import Foundation

// MARK: - Section

struct SectionSettingsViewModel {
    let title: String
    let options: [SetcionOptionSettingsViewModel]
}

// MARK: - Option

struct SetcionOptionSettingsViewModel {
    let title: String
    let handler: () -> Void
}
