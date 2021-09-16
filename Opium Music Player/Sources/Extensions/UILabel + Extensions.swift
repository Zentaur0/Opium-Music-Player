//
//  UILabel + Extensions.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 11.09.2021.
//

import UIKit

extension UILabel {
    func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = .lightGray
        self.addSubview(separator)
        
        separator.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 30)
            $0.height.equalTo(0.5)
            $0.top.equalTo(self.snp.bottom)
        }
    }
}
