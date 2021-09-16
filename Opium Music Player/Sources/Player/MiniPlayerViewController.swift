//
//  MiniPlayerViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 12.09.2021.
//

import UIKit

// MARK: - MiniPlayerDelegate

protocol MiniPlayerDelegate: AnyObject {
    func configureMiniPlayer(viewModel: DetailedViewModel)
}

// MARK: - MiniPlayerView

final class MiniPlayerView: UIViewController {
    
    // MARK: - Properties
    
    private var isPlaying = true
    private let songImageView = UIImageView()
    private let songLabel = UILabel()
    private let contentView = UIView()
    private let playPauseButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    
    private lazy var playerButtonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playPauseButton, nextButton])
        stack.distribution = .fillEqually
        stack.spacing = 15
        return stack
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupConstraints()
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .changePlayPauseMini, object: nil)
    }
    
}

extension MiniPlayerView: MiniPlayerDelegate {
    
    func configureMiniPlayer(viewModel: DetailedViewModel) {
        configure(viewModel: viewModel)
    }
    
}

// MARK: - Methods

extension MiniPlayerView {
    
    func configure(viewModel: DetailedViewModel) {
        songImageView.sd_setImage(with: viewModel.image ?? URL(fileURLWithPath: ""))
        songLabel.text = viewModel.name
    }
    
    private func setupVC() {
        playPauseButton.tintColor = R.color.darkLight()
        playPauseButton.setImage(R.image.pausePlay(), for: .normal)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        
        nextButton.tintColor = R.color.darkLight()
        nextButton.setImage(R.image.playnext(), for: .normal)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
        view.addSubview(contentView)
        
        addBlurEffect()
        
        contentView.addSubview(songImageView)
        contentView.addSubview(songLabel)
        contentView.addSubview(playerButtonsStackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapMiniPlayer))
        view.addGestureRecognizer(tap)
        
        PlayerPresenter.shared.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didTapPlayPause),
                                               name: .changePlayPauseMini,
                                               object: nil)
    }
    
    private func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        songImageView.snp.makeConstraints {
            $0.width.equalTo(songImageView.snp.height)
            $0.leading.top.bottom.equalToSuperview().inset(8)
        }
        
        songLabel.snp.makeConstraints {
            $0.leading.equalTo(songImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(playerButtonsStackView.snp.leading).offset(-15)
            $0.centerY.equalToSuperview()
        }
        
        playerButtonsStackView.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview().inset(20)
            $0.width.equalTo(60)
        }
        
    }
    
    private func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.85
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(blurEffectView)
        
        blurEffectView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
    }
    
}

// MARK: - Actions

extension MiniPlayerView {
    
    @objc private func didTapPlayPause() {
        isPlaying = !isPlaying
        playPauseButton.setImage(isPlaying ? R.image.pausePlay() : R.image.startPlay(), for: .normal)
        NotificationCenter.default.post(name: .didTapPlay, object: nil)
    }
    
    @objc private func didTapNext() {
        let number = 1
        NotificationCenter.default.post(name: .didTapNext, object: number)
    }
    
    @objc private func didTapMiniPlayer() {
        NotificationCenter.default.post(name: .openPlayer, object: nil)
    }
    
}
