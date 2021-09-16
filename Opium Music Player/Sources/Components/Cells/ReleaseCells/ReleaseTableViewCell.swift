//
//  ReleaseTableViewCell.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 07.08.2021.
//

import UIKit

// MARK: - ReleaseTableViewCell

final class ReleaseTableViewCell: UITableViewCell {

    // MARK: - Static
    
    static let reuseID = "ReleaseTableViewCell"

    // MARK: - Properties
    
    var collection: UICollectionView?

    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Methods

extension ReleaseTableViewCell {
    
    private func setupCell() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)

        guard let collection = collection else { return }

        collection.isPagingEnabled = true
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(ReleaseCollectionViewCell.self,
                            forCellWithReuseIdentifier: ReleaseCollectionViewCell.reuseID)
        contentView.addSubview(collection)

        backgroundColor = .clear
    }

    private func setupConstraints() {
        guard let collection = collection else { return }

        collection.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
