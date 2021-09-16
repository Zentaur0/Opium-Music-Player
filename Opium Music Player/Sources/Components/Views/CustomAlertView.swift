//
//  CustomAlertView.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 11.09.2021.
//

import UIKit

// MARK: - AlertType

enum AlertType {
    case success
    case failure
    case `default`
}

// MARK: - CustomAlertView

final class CustomAlertView: UIView {
    
    // MARK: - Properties
    
    private let alertLabel = UILabel()
    private let alertView = UIView()
    private var type: AlertType?
    private let successColor: UIColor = .systemBlue
    private let failureColor: UIColor = .systemRed
    private var initialCenter = CGPoint()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewController(type: type ?? .default)
        setupConstraints()
    }
    
    convenience init(text: String, type: AlertType) {
        self.init()
        self.alertLabel.text = text
        setupViewController(type: type)
        setupConstraints()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Methods

extension CustomAlertView {
    
    private func setupViewController(type: AlertType) {
        switch type {
        case .failure:
            alertView.backgroundColor = failureColor
        case .success:
            alertView.backgroundColor = successColor
        case .default:
            alertView.backgroundColor = .lightGray
        }
        
        alertLabel.numberOfLines = 0
        alertLabel.textAlignment = .center
        alertLabel.textColor = .white
        alertView.layer.cornerRadius = 13
        alertView.addSubview(alertLabel)
        
        addSubview(alertView)
        backgroundColor = .clear
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragInteraction))
        addGestureRecognizer(panGesture)
    }
    
    private func setupConstraints() {
        alertView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide).inset(25)
            $0.height.equalTo(55)
        }
        
        alertLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(5)
        }
    }
    
}

// MARK: - Actions

extension CustomAlertView {
    
    @objc func dragInteraction(_ gesture: UIPanGestureRecognizer) {
        guard let piece = gesture.view else {return}
        
        let translation = gesture.translation(in: piece.superview)
        
        switch gesture.state {
        case .began:
            initialCenter = piece.center
        case .cancelled, .ended:
            if translation.y < -30{
                UIView.animate(withDuration: 0.2) {
                    self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: -130)
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
                }
            }
        default:
            if translation.y <= 70 {
                let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
                piece.center = newCenter
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.center = self.initialCenter
                }
            }
        }
    }
    
}
