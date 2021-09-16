//
//  PlayerPresebter.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.09.2021.
//

import UIKit
import AVFoundation
import MediaPlayer

// MARK: - PlayerDataSource

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
    var artistID: String? { get }
}

// MARK: - PlayerPresenter

final class PlayerPresenter {
    
    // MARK: - Static
    
    static let shared = PlayerPresenter()
    
    // MARK: - Properties
    
    weak var delegate: MiniPlayerDelegate?
    private var index = 0
    private var player: AVPlayer?
    private var playerQueue: AVQueuePlayer?
    private var track: AudioTrack?
    private var tracks: [AudioTrack] = []
    private var playerVC: PlayerViewController?
    
    private var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if !tracks.isEmpty {
            return tracks[index]
        }
        return nil
    }
    
    // MARK: - Init
    
    private init() {}
    
}

// MARK: - Methods

extension PlayerPresenter {
    
    func presentPlayer(track: AudioTrack, isPlaying: Bool) {
        let vc = PlayerViewController(track: track, isPlaying: isPlaying)
        vc.dataSource = self
        vc.delegate = self
        playerVC = vc
        UIApplication.topViewController()?
            .present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    func startPlaying(track: AudioTrack? = nil, tracks: [AudioTrack]? = nil) {
        var vc: PlayerViewController?
        
        if let track = track,
           let tracks = tracks,
           tracks.count > 1 {
            vc = playTrackInAlbum(track: track, tracks: tracks)
        } else if let track = track {
            vc = playSingleTrack(track: track)
        } else if let tracks = tracks {
            vc = playAll(tracks: tracks)
        }
        
        self.checkIfPlayerIsPlaying()
        
        vc?.dataSource = self
        vc?.delegate = self
        
        self.playerVC = vc
        
        if let _ = UIApplication.topViewController() as? PlayerViewController {
            return
        } else {
            UIApplication.topViewController()?
                .present(UINavigationController(rootViewController: vc ?? UIViewController()), animated: true) {
                    self.postPlayerNotifications(tracks: tracks)
                }
        }
    }
    
    func checkIfPlayerIsPlaying(completion: ((Bool) -> Void)) {
        if let player = self.player, player.timeControlStatus == .playing {
            completion(true)
        } else if let player = self.playerQueue, player.timeControlStatus == .playing {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    private func checkIfPlayerIsPlaying() {
        if let player = self.player, player.timeControlStatus == .playing {
            player.pause()
            
        }
        
        if let player = self.playerQueue, player.timeControlStatus == .playing {
            player.pause()
        }
    }
    
    private func postPlayerNotifications(tracks: [AudioTrack]?) {
        NotificationCenter.default.post(name: .removeMiniPlayer, object: nil)
        if tracks?.count ?? 1 < 2 {
            NotificationCenter.default.post(name: .addMiniPlayer, object: track)
            NotificationCenter.default.post(name: .observeTrack, object: track)
        } else {
            NotificationCenter.default.post(name: .addMiniPlayer, object: tracks?[self.index])
            NotificationCenter.default.post(name: .observeTrack, object: tracks?[self.index])
        }
    }
    
    // MARK: - PlaySingleTrack
    /// Setup single track playing
    private func playSingleTrack(track: AudioTrack) -> PlayerViewController? {
        self.track = track
        self.tracks = []
        
        guard let url = URL(string: track.preview_url ?? "") else {
            AppContainer.showAlert(type: .failure, text: APIError.wrongProvidedURL.localizedDescription)
            return nil
        }
        
        self.player = AVPlayer(url: url)
        self.playerQueue = nil
        
        let vc = PlayerViewController(track: track)
        self.player?.play()
        
        return vc
    }
    
    // MARK: - PlayAllTracks
    /// Setup playing all tracks
    private func playAll(tracks: [AudioTrack]) -> PlayerViewController? {
        if self.index > 0 {
            self.index = 0
        }
        
        self.track = tracks[0]
        self.tracks = tracks
        
        guard let track = self.track, let index = tracks.firstIndex(of: track) else {
            AppContainer.showAlert(type: .failure, text: APIError.wrongProvidedURL.localizedDescription)
            return nil
        }
        
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else { return nil }
            return  AVPlayerItem(url: url)
        })
        
        self.player = nil
        
        let vc = PlayerViewController(track: tracks[index])
        self.playerQueue?.play()
        
        return vc
    }
    
    // MARK: - PlayTrackInAlbum
    /// Setup playing chosen track in album
    private func playTrackInAlbum(track: AudioTrack, tracks: [AudioTrack]) -> PlayerViewController? {
        if let _ = player {
            self.player = nil
        }
        
        if let _ = playerQueue {
            self.playerQueue = nil
        }
        
        self.track = track
        self.tracks = tracks
        
        index = tracks.firstIndex(of: track) ?? 0
        
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else { return nil }
            return  AVPlayerItem(url: url)
        })
        
        let vc = PlayerViewController(track: tracks[index])
        self.playerQueue?.replaceCurrentItem(
            with: AVPlayerItem(url: URL(string: track.preview_url ?? "") ?? URL(fileURLWithPath: ""))
        )
        self.playerQueue?.play()
        
        return vc
    }
    
    private func setupIndexWhenNextTapped(notification: Notification?) {
        if index != tracks.count - 1 {
            if let number = notification?.object as? Int {
                index += number
                let track = tracks[index]
                let viewModel = DetailedViewModel(name: track.name,
                                                  artistName: nil,
                                                  image: URL(string: track.album?.images?.first?.url ?? ""))
                delegate?.configureMiniPlayer(viewModel: viewModel)
            } else {
                index += 1
                NotificationCenter.default.post(name: .addMiniPlayer, object: tracks[index])
                NotificationCenter.default.post(name: .observeTrack, object: tracks[index])
                if let _ = UIApplication.topViewController() as? PlayerViewController {
                    return
                } else {
                    NotificationCenter.default.post(name: .openPlayer, object: tracks[index])
                }
            }
        }
    }
    
    private func setupIndexWhenBackTapped(notification: Notification?) {
        if index != tracks.count - 1 {
            if let number = notification?.object as? Int {
                index -= number
                let track = tracks[index]
                let viewModel = DetailedViewModel(name: track.name,
                                                  artistName: nil,
                                                  image: URL(string: track.album?.images?.first?.url ?? ""))
                delegate?.configureMiniPlayer(viewModel: viewModel)
            } else {
                index -= 1
                NotificationCenter.default.post(name: .addMiniPlayer, object: tracks[index])
                NotificationCenter.default.post(name: .observeTrack, object: tracks[index])
                if let _ = UIApplication.topViewController() as? PlayerViewController {
                    return
                } else {
                    NotificationCenter.default.post(name: .openPlayer, object: tracks[index])
                }
            }
        }
    }
    
}

// MARK: - PlayerDataSource

extension PlayerPresenter: PlayerDataSource {
    
    var songName: String? {
        currentTrack?.name
    }
    
    var subtitle: String? {
        currentTrack?.artists?.first?.name
    }
    
    var imageURL: URL? {
        URL(string: currentTrack?.album?.images?.first?.url ?? "")
    }
    
    var artistID: String? {
        currentTrack?.artists?.first?.id
    }
    
}

// MARK: - PlayerViewControllerDelegate

extension PlayerPresenter: PlayerViewControllerDelegate {
    
    func didTapPlayPause() {
        if let player = player {
            switch player.timeControlStatus {
            case .paused: player.play()
            case .playing: player.pause()
            case .waitingToPlayAtSpecifiedRate: break
            @unknown default:
                AppContainer.showAlert(type: .default, text: player.error?.localizedDescription ?? "")
            }
        } else if let player = playerQueue {
            switch player.timeControlStatus {
            case .paused: player.play()
            case .playing: player.pause()
            case .waitingToPlayAtSpecifiedRate: break
            @unknown default:
                AppContainer.showAlert(type: .default, text: player.error?.localizedDescription ?? "")
            }
        }
    }
    
    func didTapBack(notification: Notification?) {
        if tracks.isEmpty {
            player?.pause()
            guard let _ = UIApplication.topViewController(),
                  let track = track else { return }
            self.startPlaying(track: track)
        } else if let player = playerQueue {
            setupIndexWhenBackTapped(notification: notification)
            let track = tracks[index]
            playerVC?.setTrack(track: track)
            let item = AVPlayerItem(url: URL(string: track.preview_url ?? "") ?? URL(fileURLWithPath: ""))
            player.replaceCurrentItem(with: item)
            playerVC?.refreshUI()
        }
    }
    
    func didTapNext(notification: Notification?) {
        if tracks.isEmpty {
            player?.pause()
        } else if let player = playerQueue {
            setupIndexWhenNextTapped(notification: notification)
            let track = tracks[index]
            playerVC?.setTrack(track: track)
            let item = AVPlayerItem(url: URL(string: track.preview_url ?? "") ?? URL(fileURLWithPath: ""))
            player.replaceCurrentItem(with: item)
            playerVC?.refreshUI()
        }
    }
    
    func didSlideSlider(_ value: Float) {
        if let player = player {
            player.volume = value
        }
        
        if let player = playerQueue {
            player.volume = value
        }
    }
    
    func didTapArtistName() {
        let artistID = currentTrack?.artists?.first?.id
        let vc = AppContainer.makeArtistDetailedVC(artistID: artistID ?? "")
        playerVC?.onDismiss = {
            UIApplication.topViewController()?.present(vc, animated: true)
        }
        playerVC?.dismiss(animated: true)
    }
    
}
