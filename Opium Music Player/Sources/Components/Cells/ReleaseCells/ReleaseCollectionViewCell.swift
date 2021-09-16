//
//  RealeaseCollectionViewCell.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit

// MARK: - ReleaseCollectionViewCell

final class ReleaseCollectionViewCell: UICollectionViewCell {

    // MARK: - Static
    
    static let reuseID = "RealeaseCollectionViewCell"

    // MARK: - Properties
    
    private let label: UILabel = UILabel()
    private let imageView: UIImageView = UIImageView()
    private let cellView: UIView = UIView()

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Methods

extension ReleaseCollectionViewCell {
    
    func configure(indexPath: IndexPath, albums: [Album], singles: [Album]) {
        let row = indexPath.row
        
        if !albums.isEmpty {
            let albumImageURL = albums[row].images?.first?.url
            
            guard let albumURL = URL(string: albumImageURL ?? "") else { return }
            imageView.sd_setImage(with: albumURL)
            label.text = albums[row].artists.first?.name
        }
        
        if !singles.isEmpty {
            let singleImageURL = singles[row].images?.first?.url
            
            guard let singleURL = URL(string: singleImageURL ?? "") else { return }
            
            imageView.sd_setImage(with: singleURL)
            label.text = singles[row].artists.first?.name
        }
        
    }
    
    func configure(playlist: Playlist) {
        let imageURL = playlist.images.first?.url
        
        guard let url = URL(string: imageURL ?? "") else { return }
        
        imageView.sd_setImage(with: url)
        label.text = playlist.name
    }
    
    func configure(album: Album) {
        let imageURL = album.images?.first?.url
        
        guard let url = URL(string: imageURL ?? "") else { return }
        
        imageView.sd_setImage(with: url)
        label.text = album.name
    }
    
    private func setupCell() {
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
        label.textAlignment = .center

        imageView.contentMode = .scaleToFill
        
        cellView.layer.shadowOpacity = 1
        cellView.layer.shadowOffset = .zero
        cellView.layer.shadowRadius = 5
        cellView.layer.shadowColor = UIColor.gray.cgColor
        cellView.layer.shouldRasterize = true
        cellView.layer.rasterizationScale = UIScreen.main.scale

        contentView.addSubview(cellView)
        contentView.addSubview(label)
        cellView.addSubview(imageView)

        backgroundColor = .clear
    }

    private func setupConstraints() {
        cellView.snp.makeConstraints {
            $0.left.right.top.width.equalToSuperview()
            $0.height.equalTo(cellView.snp.width)
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(cellView.snp.top)
            $0.width.height.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(5)
            $0.top.equalTo(imageView.snp.bottom).offset(5)
        }
    }

}
