//
//  UINavigationController + Extensions.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 11.09.2021.
//

import UIKit

extension UINavigationController {
    func setTranslusentNavigationBar() {
        navigationBar.isOpaque = true
        navigationBar.prefersLargeTitles = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
}
