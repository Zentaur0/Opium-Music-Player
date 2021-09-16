//
//  AppContainer.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit

// MARK: - AppContainer

final class AppContainer {
    
    // MARK: - Properties
    
    private static let apiCaller = APICaller()

    // MARK: - Init
    
    private init() {}

    // MARK: - Methods
    
    static func makeAppBackgroundColor(on view: UIView) {
        view.gradientBackground(from: R.color.smoothBlueCustom() ?? .red,
                                to: R.color.smoothGreenCustom() ?? .black,
                                direction: .topToBottom)
    }
    
    // MARK: - ViewControllers
    
    static func makeRootVC() -> UIViewController {
        AuthentificationManager.shared.refreshIfNeeded(completion: nil)
        return AuthentificationManager.shared.isSignedIn ? RootViewController() : StartViewController()
    }
    
    static func makeCategoriesVC() -> CategoriesViewController {
        CategoriesViewController(apiCaller: apiCaller)
    }
    
    static func makeReleaseVC() -> ReleaseViewController {
        ReleaseViewController(apiCaller: apiCaller)
    }
    
    static func makeSearchVC() -> SearchViewController {
        SearchViewController(apiCaller: apiCaller)
    }
    
    static func makeSearchResultVC() -> SearchResultViewController {
        SearchResultViewController()
    }
    
    static func makeSettingsVC() -> SettingsViewController {
        SettingsViewController()
    }
    
    static func makeProfileViewController() -> ProfileViewController {
        ProfileViewController(apiCaller: apiCaller)
    }

    static func makePlaylistsVC(category: Category) -> PlaylistsViewController {
        PlaylistsViewController(category: category, apiCaller: apiCaller)
    }
    
    static func makeAlbumDetailedVC(album: Album) -> AlbumDetailViewController {
        AlbumDetailViewController(apiCaller: apiCaller, album: album)
    }
    
    static func makePlaylistDetailedVC(playlist: Playlist) -> PlaylistDetailViewController {
        PlaylistDetailViewController(apiCaller: apiCaller, playlist: playlist)
    }
    
    static func makeArtistDetailedVC(artistID: String) -> ArtistDetailViewController {
        ArtistDetailViewController(artistID: artistID, apiCaller: apiCaller)
    }
    
    // MARK: - Show Alert
    
    /// Show custom alert with types: .success, .failure or .default
    static func showAlert(type: AlertType, text: String) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let alert = CustomAlertView(text: text, type: type)
            appDelegate.window?.addSubview(alert)
            animateAlert(alert: alert)
        }
    }
    
    // MARK: - Alert Animation
    
    private static func animateAlert(alert: UIView) {
        
        alert.frame = CGRect(x: alert.frame.minX,
                             y: alert.frame.minY,
                             width: UIScreen.main.bounds.width,
                             height: -130)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) {
            alert.frame = CGRect(x: alert.frame.minX,
                                 y: alert.frame.maxY,
                                 width: UIScreen.main.bounds.width,
                                 height: 130)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.1) {
                alert.frame = CGRect(x: alert.frame.minX,
                                     y: alert.frame.minY,
                                     width: UIScreen.main.bounds.width,
                                     height: -130)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                alert.removeFromSuperview()
            }
        }
    }

}
