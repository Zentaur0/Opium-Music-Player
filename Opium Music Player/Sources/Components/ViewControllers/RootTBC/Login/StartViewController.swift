//
//  StartViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 31.08.2021.
//

import UIKit

// MARK: - StartViewController

final class StartViewController: UIViewController {

    // MARK: - Properties
    
    private let nameLabel: UILabel = UILabel()
    private let loginButton: UIButton = UIButton(type: .system)
    private var labelSize: CGFloat?
    private var buttonSize: CGFloat?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkSize()
        setupViewController()
        setupConstraints()
    }

}

// MARK: - Methods

extension StartViewController {
    
    private func setupViewController() {
        setupNameLabel()
        setupLoginButton()

        view.addSubview(nameLabel)
        view.addSubview(loginButton)
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }

    private func setupConstraints() {
        nameLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(164 - 44)
        }

        loginButton.snp.makeConstraints {
            $0.height.equalTo(buttonSize ?? 0)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.bottom.equalToSuperview().inset(50)
        }
    }

    private func setupNameLabel() {
        nameLabel.text = R.string.localizable.app_name()
        nameLabel.numberOfLines = 2
        nameLabel.textAlignment = .left
        nameLabel.font = .systemFont(ofSize: labelSize ?? 0, weight: .bold)
        nameLabel.insetsLayoutMarginsFromSafeArea = false
    }

    private func setupLoginButton() {
        loginButton.backgroundColor = .black
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitle(R.string.localizable.sign_in(), for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        loginButton.addTarget(self, action: #selector(openSpotifyWebViewController ), for: .touchUpInside)
    }
    
    private func checkSize() {
        let screen = UIScreen.main.bounds
        let biggestSize = screen.width > screen.height ? screen.width : screen.height
        
        if biggestSize < 600 {
            labelSize = 38
            buttonSize = 46
        } else {
            labelSize = 48
            buttonSize = 56
        }
    }
    
    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: R.string.localizable.sign_in_wrong_title(),
                                          message: R.string.localizable.sign_in_wrong_describing(),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.cancel_title(), style: .cancel, handler: nil))
            return
        }
        
        let vc = AppContainer.makeRootVC()
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }

}

// MARK: - Actions

extension StartViewController {
    
    @objc private func openSpotifyWebViewController() {
        let vc = SpotifyWebViewController()
        let navVC = UINavigationController(rootViewController: vc)
        
        vc.onClose = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        
        navVC.modalPresentationStyle = .overFullScreen
        
        present(navVC, animated: true)
    }

}
