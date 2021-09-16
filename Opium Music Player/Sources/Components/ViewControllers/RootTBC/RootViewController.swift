//
//  LoginVC.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit
import AVFoundation

// MARK: - RootTabBarActionsProtocol

@objc fileprivate protocol RootTabBarActionsProtocol {
    @objc func removeMiniPlayer()
    @objc func openPlayer()
    @objc func addMiniPlayer(notification: Notification)
}

// MARK: - Properties

final class RootViewController: UIViewController {

    // MARK: - Properties
    
    private var categoriesVC: UINavigationController?
    private var newReliasesVC: UINavigationController?
    private var searchVC: UINavigationController?
    private let miniPlayer = MiniPlayerView()
    let childTabBarController = UITabBarController()
    private var track: AudioTrack?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
        setupObservers()
    }
    
}

// MARK: - Methods

extension RootViewController {
    
    private func setupTabBarController() {
        categoriesVC = UINavigationController(rootViewController: AppContainer.makeCategoriesVC())
        newReliasesVC = UINavigationController(rootViewController: AppContainer.makeReleaseVC())
        searchVC = UINavigationController(rootViewController: AppContainer.makeSearchVC())

        guard let categoriesVC = categoriesVC,
              let newReliasesVC = newReliasesVC,
              let searchVC = searchVC else { return }

        categoriesVC.tabBarItem.image = R.image.library()
        newReliasesVC.tabBarItem.image = R.image.music()
        searchVC.tabBarItem.image = R.image.search()
        
        categoriesVC.title = R.string.localizable.categories()
        newReliasesVC.title = R.string.localizable.releases()
        searchVC.title = R.string.localizable.search()
        
        categoriesVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray],
                                                       for: .normal)
        categoriesVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: R.color.darkLight()],
                                                       for: .selected)
        newReliasesVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray],
                                                        for: .normal)
        newReliasesVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: R.color.darkLight()],
                                                        for: .selected)
        searchVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray],
                                                   for: .normal)
        searchVC.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: R.color.darkLight()],
                                                   for: .selected)

        categoriesVC.navigationBar.prefersLargeTitles = true
        categoriesVC.navigationItem.largeTitleDisplayMode = .always
        newReliasesVC.navigationBar.prefersLargeTitles = true
        newReliasesVC.navigationItem.largeTitleDisplayMode = .always
        searchVC.navigationBar.prefersLargeTitles = true
        searchVC.navigationItem.largeTitleDisplayMode = .always

        addChild(childTabBarController)
        view.addSubview(childTabBarController.view)
        childTabBarController.didMove(toParent: self)
        childTabBarController.tabBar.tintColor = R.color.darkLight()
        childTabBarController.tabBar.backgroundImage = UIImage()
        childTabBarController.tabBar.backgroundColor = .clear
        childTabBarController.setViewControllers([categoriesVC, newReliasesVC, searchVC], animated: true)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addMiniPlayer),
                                               name: .addMiniPlayer,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeMiniPlayer),
                                               name: .removeMiniPlayer,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openPlayer),
                                               name: .openPlayer,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeTrack),
                                               name: .observeTrack,
                                               object: nil)
    }

}

// MARK: - RootTabBarProtocol

extension RootViewController: RootTabBarActionsProtocol {
    
    @objc fileprivate func removeMiniPlayer() {
        miniPlayer.willMove(toParent: nil)
        miniPlayer.view.removeFromSuperview()
        miniPlayer.removeFromParent()
    }
    
    @objc fileprivate func openPlayer() {
        if let track = track {
            PlayerPresenter.shared.checkIfPlayerIsPlaying { isPlaying in
                PlayerPresenter.shared.presentPlayer(track: track, isPlaying: isPlaying)
            }
        }
    }
    
    @objc func observeTrack(notification: Notification) {
        guard let playingTrack = notification.object as? AudioTrack else { return }
        self.track = playingTrack
    }
    
    @objc fileprivate func addMiniPlayer(notification: Notification) {
        addChild(miniPlayer)
        view.addSubview(miniPlayer.view)
        miniPlayer.didMove(toParent: self)
        
        miniPlayer.view.snp.makeConstraints {
            $0.bottom.equalTo(childTabBarController.tabBar.snp.top)
            $0.width.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        guard let track = notification.object as? AudioTrack else { return }
        
        let viewModel = DetailedViewModel(name: track.name,
                                          artistName: nil,
                                          image: URL(string: track.album?.images?.first?.url ?? ""))
        
        miniPlayer.configure(viewModel: viewModel)
    }
    
}
