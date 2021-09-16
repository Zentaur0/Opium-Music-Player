//
//  NotificationCenter + Extensions.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 13.09.2021.
//

import Foundation

extension Notification.Name {
    static let didTapPlay = Notification.Name("didTapPlay")
    static let didTapNext = Notification.Name("didTapNext")
    static let addMiniPlayer = Notification.Name("addMiniPlayer")
    static let removeMiniPlayer = Notification.Name("removeMiniPlayer")
    static let openPlayer = Notification.Name("openPlayer")
    static let observeTrack = Notification.Name("observeTrack")
    static let changePlayPauseMini = Notification.Name("changePlayPauseMini")
}
