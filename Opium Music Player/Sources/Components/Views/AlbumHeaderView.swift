//
//  Header.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 30.08.2021.
//

import UIKit

// MARK: - HeaderViewDelegate

protocol HeaderViewDelegate: AnyObject {
    func playAllButtonTapped()
}

// MARK: - HeaderArtistButtonDelegate

protocol HeaderAlbumViewDelegate: AnyObject {
    func openArtistPage()
}

// MARK: - HeaderView

final class AlbumHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Static
    
    static let reuseID = "AlbumHeaderView"
    
    // MARK: - Properties
    
    weak var delegate: HeaderViewDelegate?
    weak var artistDelegate: HeaderAlbumViewDelegate?
    
    private let headerImageView = UIImageView()
    private let headerNamelabel = UILabel()
    private let headerAlbumLabel = UILabel()
    private let headerDescriptionLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private let playButtonView = UIView()
    private let artistNameButton = UIButton(type: .system)
    
    private lazy var headerStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [headerAlbumLabel, headerDescriptionLabel, artistNameButton, playButtonView]
        )
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupHeader()
        setupConstraints()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Methods

extension AlbumHeaderView {
    
    func configure(with viewModel: HeaderViewModel) {
        guard let url = URL(string: viewModel.image) else { return }
        
        headerImageView.sd_setImage(with: url)
        headerAlbumLabel.text = viewModel.album
        headerDescriptionLabel.text = viewModel.description
        artistNameButton.setTitle(viewModel.name, for: .normal)
    }
    
    private func setupHeader() {
        artistNameButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        artistNameButton.addTarget(self, action: #selector(didTapArtistButton), for: .touchUpInside)
        
        headerAlbumLabel.textAlignment = .center
        headerAlbumLabel.font = .systemFont(ofSize: 17, weight: .bold)
        headerAlbumLabel.numberOfLines = 0
        
        headerDescriptionLabel.textAlignment = .center
        headerDescriptionLabel.numberOfLines = 0
        
        headerImageView.layer.cornerRadius = 8
        headerImageView.clipsToBounds = true
        
        headerStackView.setCustomSpacing(15, after: headerNamelabel)
        
        playButtonView.addSubview(playButton)
        playButton.layer.cornerRadius = 14
        playButton.backgroundColor = .systemBlue
        playButton.setTitleColor(.white, for: .normal)
        playButton.setTitle(R.string.localizable.play_all_songs(), for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        
        contentView.addSubview(headerImageView)
        contentView.addSubview(headerStackView)
        
        contentView.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        headerImageView.snp.makeConstraints {
            $0.width.height.equalTo(200)
            $0.top.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
        
        headerStackView.snp.makeConstraints {
            $0.top.equalTo(headerImageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.bottom.equalToSuperview().inset(15).priority(999)
            $0.centerX.equalToSuperview()
        }
        
        playButtonView.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        playButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
        }
    }
    
}

// MARK: - Action

extension AlbumHeaderView {
    
    @objc private func didTapPlayButton() {
        delegate?.playAllButtonTapped()
    }
    
    @objc private func didTapArtistButton() {
        artistDelegate?.openArtistPage()
    }
    
}

