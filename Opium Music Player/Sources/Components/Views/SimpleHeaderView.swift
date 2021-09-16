//
//  SimpleHeaderView.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 07.09.2021.
//

import UIKit

// MARK: - SimpleView

final class SimpleView: UIView {
    
    // MARK: - Properties
    
    private let label = UILabel()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupFrames()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Methods

extension SimpleView {
    
    func configure(text: String) {
        label.text = text
    }
    
    private func setupView() {
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.addSeparator()
        addSubview(label)
        
    }
    
    private func setupFrames() {
        let width = UIScreen.main.bounds.width
        label.frame = CGRect(x: 20, y: 0, width: width / 2, height: 20)
        frame = CGRect(x: 0, y: 0, width: width, height: 50)
    }
    
}
