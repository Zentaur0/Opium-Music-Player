//
//  CategoryTableViewCell.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit

// MARK: - CategoryCollectionViewCell

final class CategoryCollectionViewCell: UICollectionViewCell {

    // MARK: - Static
    
    static let reuseID = "CategoryTableViewCell"

    // MARK: - Properties
    
    private let label: UILabel = UILabel()
    private let imageView: UIImageView = UIImageView()
    private let colors: Set =
        ["grass.green.custom",
         "green.custom",
         "light.blue.custom",
         "light.green.custom",
         "light.violet.custom",
         "orange.custom",
         "violet.custom",
         "yellow.custom"]

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

extension CategoryCollectionViewCell {
    
    private func setupCell() {
        label.textColor = .black
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        
        imageView.image = R.image.playlist()
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        contentView.gradientBackground(from: UIColor(named: colors.randomElement() ?? "") ?? .lightGray,
                                       to: UIColor(named: colors.randomElement() ?? "") ?? .magenta,
                                       direction: .rightToLeft)
        
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }

    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        imageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(10)
            $0.height.width.equalTo(30)
        }
    }

    func configure(category: Category) {
        label.text = category.name
    }

}
