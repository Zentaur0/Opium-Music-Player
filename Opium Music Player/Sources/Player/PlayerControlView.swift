//
//  PlayerControllView.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.09.2021.
//

import UIKit
import MediaPlayer

enum PlayerKeys: String {
    case volumeSlider = "volume_slider_value"
}

// MARK: - PlayerControlViewDelegate

protocol  PlayerControlViewDelegate: AnyObject {
    func playerControlViewDidTapPlayPause()
    func playerControlViewDidTapBack()
    func playerControlViewDidTapNext()
    func playerControlView(didSlideVolume value: Float)
    func playerControlViewDidTapArtistName()
}

// MARK: - PlayerControllView

final class PlayerControlView: UIView {
    
    // MARK: - Properties
    
    var isPlaying = true
    weak var delegate: PlayerControlViewDelegate?
    private let volumeSlider = UISlider()
    private let nameButton = UIButton()
    private let subtitleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let playButton = UIButton(type: .system)
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [backButton, playButton, nextButton])
        stack.distribution = .fillEqually
        stack.spacing = 70
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        playButton.setImage(isPlaying ? R.image.pausePlay() : R.image.startPlay(), for: .normal)
    }
    
}

// MARK: - Methods

extension PlayerControlView {
    
    func configure(with viewModel: PlayerControlViewModel) {
        nameButton.setTitle(viewModel.subtitle, for: .normal)
        subtitleLabel.text = viewModel.title
    }
    
    private func setupView() {
        volumeSlider.tintColor = R.color.darkLight()
        volumeSlider.value = UserDefaults.standard.float(forKey: PlayerKeys.volumeSlider.rawValue)
        volumeSlider.addTarget(self, action: #selector(didSlideSlider), for: .valueChanged)
        
        nameButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        nameButton.addTarget(self, action: #selector(didTapArtistName), for: .touchUpInside)
        nameButton.setTitleColor(.systemBlue, for: .normal)
        
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 20, weight: .regular)
        
        backButton.tintColor = R.color.darkLight()
        backButton.setImage(R.image.playback(), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        nextButton.tintColor = R.color.darkLight()
        nextButton.setImage(R.image.playnext(), for: .normal)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
        playButton.tintColor = R.color.darkLight()
        playButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        
        backgroundColor = .clear
        
        addSubview(nameButton)
        addSubview(subtitleLabel)
        addSubview(volumeSlider)
        addSubview(buttonStack)
        
        clipsToBounds = true
    }
    
    private func setupConstraints() {
        subtitleLabel.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalToSuperview()
            $0.top.equalToSuperview().inset(15)
        }
        
        nameButton.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.width.equalToSuperview()
            $0.top.equalTo(subtitleLabel.snp.bottom).inset(10)
        }
        
        buttonStack.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.top.equalTo(nameButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        volumeSlider.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.top.equalTo(buttonStack.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints {
            $0.width.equalTo(30)
        }
        
        nextButton.snp.makeConstraints {
            $0.width.equalTo(30)
        }
        
        playButton.snp.makeConstraints {
            $0.width.equalTo(30)
        }
    }
    
}

// MARK: - Actions

extension PlayerControlView {
    
    @objc private func didTapBack() {
        isPlaying = isPlaying ? isPlaying : !isPlaying
        playButton.setImage(isPlaying ? R.image.pausePlay() : R.image.startPlay(), for: .normal)
        NotificationCenter.default.post(name: .changePlayPauseMini, object: nil)
        delegate?.playerControlViewDidTapBack()
    }
    
    @objc private func didTapNext() {
        delegate?.playerControlViewDidTapNext()
    }
    
    @objc private func didTapPlayPause() {
        isPlaying = !isPlaying
        playButton.setImage(isPlaying ? R.image.pausePlay() : R.image.startPlay(), for: .normal)
        NotificationCenter.default.post(name: .changePlayPauseMini, object: nil)
        delegate?.playerControlViewDidTapPlayPause()
    }
    
    @objc private func didSlideSlider(_ slider: UISlider, _ notification: NSNotification) {
        let value = slider.value
        UserDefaults.standard.setValue(value, forKey: PlayerKeys.volumeSlider.rawValue)
        delegate?.playerControlView(didSlideVolume: value)
    }
    
    @objc private func didTapArtistName() {
        delegate?.playerControlViewDidTapArtistName()
    }
    
}
