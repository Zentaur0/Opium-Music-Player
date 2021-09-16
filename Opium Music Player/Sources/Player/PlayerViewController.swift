//
//  PlayerViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.09.2021.
//

import UIKit
import SDWebImage

// MARK: - PlayerViewControllerDelegate

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapBack(notification: Notification?)
    func didTapNext(notification: Notification?)
    func didSlideSlider(_ value: Float)
    func didTapArtistName()
}

// MARK: - PlayerViewController

final class PlayerViewController: UIViewController {
    
    // MARK: - Properties

    var isPlaying: Bool?
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    private let imageView = UIImageView()
    private var track: AudioTrack
    private lazy var playerView: PlayerControlView = {
        let view = PlayerControlView()
        view.isPlaying = isPlaying ?? true
        return view
    }()
    
    // MARK: - Init
    
    init(track: AudioTrack) {
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(track: AudioTrack, isPlaying: Bool) {
        self.init(track: track)
        self.isPlaying = isPlaying
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupConstraints()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removePlayerObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        addPlayerObservers()
    }
    
}

// MARK: - Methods

extension PlayerViewController {
    
    func refreshUI() {
        configure()
    }
    
    func setTrack(track: AudioTrack?) {
        guard let track = track else { return }
        self.track = track
    }
    
    private func setupVC() {
        playerView.delegate = self
        
        imageView.contentMode = .scaleAspectFill
        
        view.addSubview(imageView)
        view.addSubview(playerView)
        
        setupNavigationBar()
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.height.equalTo(view.frame.width - 30)
        }
        
        playerView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(imageView.snp.bottom)
        }
    }
    
    private func configure() {
        let track = PlayerControlViewModel(title: dataSource?.songName,
                                           subtitle: dataSource?.subtitle,
                                           imageURL: dataSource?.imageURL,
                                           artistAD: dataSource?.artistID)
        imageView.sd_setImage(with: track.imageURL)
        playerView.configure(with: track)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(didTapClose))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                           target: self,
                                                           action: #selector(didTapAction))
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func addPlayerObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerDidTapPlay),
                                               name: .didTapPlay,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(miniPlayerDidTapNext),
                                               name: .didTapNext,
                                               object: nil)
    }
    
    private func removePlayerObservers() {
        NotificationCenter.default.removeObserver(self, name: .didTapPlay, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didTapNext, object: nil)
    }
    
}

// MARK: - Actions

extension PlayerViewController {
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapAction() {
        guard let url = URL(string: track.external_urls?.spotify ?? "") else { return }
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    @objc private func miniPlayerDidTapPlay() {
        delegate?.didTapPlayPause()
    }
    
    @objc private func miniPlayerDidTapNext(notification: Notification) {
        delegate?.didTapNext(notification: notification)
    }
    
}

// MARK: - PlayerControlViewDelegate

extension PlayerViewController: PlayerControlViewDelegate {
    
    func playerControlViewDidTapPlayPause() {
        delegate?.didTapPlayPause()
    }
    
    func playerControlViewDidTapBack() {
        delegate?.didTapBack(notification: nil)
    }
    
    func playerControlViewDidTapNext() {
        delegate?.didTapNext(notification: nil)
    }
    
    func playerControlView(didSlideVolume value: Float) {
        delegate?.didSlideSlider(value)
    }
    
    func playerControlViewDidTapArtistName() {
        delegate?.didTapArtistName()
    }
    
}
