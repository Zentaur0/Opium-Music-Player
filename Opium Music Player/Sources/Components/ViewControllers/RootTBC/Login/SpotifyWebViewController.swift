//
//  SpotifyWebViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 31.08.2021.
//

import UIKit
import WebKit

// MARK: - SpotifyWebViewController

final class SpotifyWebViewController: UIViewController {

    // MARK: - Properties
    
    var onClose: ((Bool) -> Void)?
    private let webView: WKWebView = WKWebView()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupConstraints()
        loadRequest()
    }

}

// MARK: - Methods

extension SpotifyWebViewController {
    
    // MARK: - Setup
    
    private func setupViewController() {
        webView.navigationDelegate = self

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(close))

        view.backgroundColor = .white
        view.addSubview(webView)
    }

    private func setupConstraints() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    // MARK: - Request
    
    private func loadRequest() {
        guard let url = AuthentificationManager.shared.signInURL else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func getParameters(fragments: String) -> [String : String] {
        let parameters = fragments.components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, parameters in
                var dictionary = result
                let key = parameters[0]
                let value = parameters[1]
                dictionary[key] = value
                return dictionary
            }
        
        return parameters
    }
    
}

// MARK: - Actions

extension SpotifyWebViewController {
    
    @objc private func close() {
        dismiss(animated: true)
    }

}

// MARK: - WKNavigationDelegate

extension SpotifyWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        let components = URLComponents(string: url.absoluteString)
        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else { return }
        
        webView.isHidden = true
        
        AuthentificationManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
                self?.onClose?(success)
                AppContainer.showAlert(type: .success, text: R.string.localizable.auth_success())
            }
        }
    }

}
