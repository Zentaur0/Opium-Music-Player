//
//  AlbumSongCell.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 07.09.2021.
//

import UIKit

// MARK: - AlbumSongCell

final class AlbumSongCell: UITableViewCell {
    
    // MARK: - Static
    
    static let reuseID = "AlbumSongCell"
    
    // MARK: - Properties
    
    private let songNameLabel = UILabel()
    
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

extension AlbumSongCell {
    
    func configureCell(viewModel: DetailedViewModel) {
        songNameLabel.text = viewModel.name
    }
    
    private func setupCell() {
        songNameLabel.textAlignment = .left
        
        contentView.addSubview(songNameLabel)
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupConstraints() {
        songNameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
}
