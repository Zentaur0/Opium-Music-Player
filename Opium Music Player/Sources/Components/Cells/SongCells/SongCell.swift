//
//  SongCell.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 30.08.2021.
//

import UIKit

// MARK: - SongCell

final class SongCell: UITableViewCell {
    
    // MARK: - Static
    
    static let reuseID = "SongCell"
    
    // MARK: - Properties
    
    private let songImageView = UIImageView()
    private let songNameLabel = UILabel()
    private let songArtistLabel = UILabel()
    private let songStackView = UIStackView()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
        setupCell()
        setupConstraints()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Methods

extension SongCell {
    
    func configureCell(viewModel: DetailedViewModel) {
        songImageView.sd_setImage(with: viewModel.image)
        songArtistLabel.text = viewModel.artistName
        songNameLabel.text = viewModel.name
    }
    
    private func setupCell() {
        songStackView.axis = .vertical
        songStackView.spacing = 5
        songStackView.distribution = .fillProportionally
        
        songNameLabel.textAlignment = .left
        songArtistLabel.textAlignment = .left
        songArtistLabel.font = .systemFont(ofSize: 13)
        
        songImageView.layer.cornerRadius = 3
        songImageView.layer.masksToBounds = true
        
        contentView.addSubview(songImageView)
        contentView.addSubview(songStackView)
        songStackView.addArrangedSubview(songNameLabel)
        songStackView.addArrangedSubview(songArtistLabel)
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupConstraints() {
        songImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(5)
            $0.width.equalTo(songImageView.snp.height)
        }
        
        songStackView.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview().inset(5)
            $0.leading.equalTo(songImageView.snp.trailing).offset(10)
        }
    }
    
}
