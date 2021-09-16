//
//  NetworkManager.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 31.08.2021.
//

import UIKit

// MARK: - Constants

fileprivate struct Constants {
    
    /// App ID
    static let clientID = "d52c650b01194d10af2f23ba2cb568b7"
    /// App secret
    static let clientSecret = "505149a83b9440128a9489d2f20d25d3"
    /// Token API URL
    static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    /// App unique redirect URI
    static let redirectURI = "http://opium-music-app/callback/"
    /// Scopes
    static let scopes = "\(Scope.userRead)%20\(Scope.readPlaylist)%20\(Scope.readPlaylistCollab)%20\(Scope.readLibrary)%20\(Scope.readFollow)%20\(Scope.streaming)%20\(Scope.userEmail)"
    
    /// List of scopes
    private struct Scope {
        static let userEmail = "user-read-email"
        static let userRead = "user-read-private"
        static let readPlaylist = "playlist-read-private"
        static let readPlaylistCollab = "playlist-read-collaborative"
        static let readLibrary = "user-library-read"
        static let readFollow = "user-follow-read"
        static let streaming = "streaming"
    }
    
}

enum AuthentificationKeys: String {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expirationDate = "expirationDate"
}

// MARK: - NetworkManager

final class AuthentificationManager {
    
    // MARK: - Static
    
    static let shared = AuthentificationManager()
    
    // MARK: - Properties
    var signInURL: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "accounts.spotify.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: Constants.clientID),
            URLQueryItem(name: "scope", value: Constants.scopes),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "show_dialog", value: "true")
        ]
        
        return urlComponents.url
    }
    
    private var refreshingToken = false
    private var onRefreshBlocks = [(String) -> Void]()
    
    // MARK: - Computed Properties
    
    var isSignedIn: Bool {
        accessToken != nil
    }
    
    private var accessToken: String? {
        UserDefaults.standard.string(forKey: AuthentificationKeys.accessToken.rawValue)
    }
    
    private var refreshToken: String? {
        UserDefaults.standard.string(forKey: AuthentificationKeys.refreshToken.rawValue)
    }
    
    private var tokenExpirationDate: Date? {
        UserDefaults.standard.object(forKey: AuthentificationKeys.expirationDate.rawValue) as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else { return false }
        
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    // MARK: - Init
    
    private init() {}
    
}

// MARK: - Methods

extension AuthentificationManager {
    
    func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let tokenData = basicToken.data(using: .utf8)
        
        guard let base64String = tokenData?.base64EncodedString() else {
            AppContainer.showAlert(type: .failure, text: "failure to get base64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = urlComponents.query?.data(using: .utf8)
        
        let session = URLSession.shared.dataTask(with: request) { data, _, error in
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthentificationResponse.self, from: data)
                self.cacheToken(result: result)
                
                completion(true)
            } catch {
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
                completion(false)
            }
        }
        
        session.resume()
    }
    
    /// Supplies valid token to be used with API Calls
    func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    /// This method refresh token if one is expired
    func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        guard !refreshingToken else { return }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else { return }
        
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        refreshingToken = true
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = urlComponents.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        let tokenData = basicToken.data(using: .utf8)
        
        guard let base64String = tokenData?.base64EncodedString() else {
            AppContainer.showAlert(type: .failure, text: "failure to get base64")
            completion?(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            
            guard let data = data else {
                completion?(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthentificationResponse.self, from: data)
                self?.onRefreshBlocks.forEach { $0(result.access_token) }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                
                completion?(true)
            } catch {
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
                completion?(false)
            }
        }.resume()
    }
    
    /// Caching token
    private func cacheToken(result: AuthentificationResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: AuthentificationKeys.accessToken.rawValue)
        if let refreshToken = result.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: AuthentificationKeys.refreshToken.rawValue)
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: AuthentificationKeys.expirationDate.rawValue)
    }
    
    func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil, forKey: AuthentificationKeys.accessToken.rawValue)
        UserDefaults.standard.setValue(nil, forKey: AuthentificationKeys.refreshToken.rawValue)
        UserDefaults.standard.setValue(nil,
                                       forKey: AuthentificationKeys.expirationDate.rawValue)
        AppContainer.showAlert(type: .success, text: R.string.localizable.sign_out())
        completion(true)
    }
    
}
