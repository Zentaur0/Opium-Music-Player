//
//  ArtistAlbumsViewController.swift
//  Opium Music Player
//
//  Created by Антон Сивцов on 23.09.2021.
//

import UIKit

// MARK: - ArtistAlbumsViewController

final class ArtistAlbumsViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var apiCaller: ArtistApiCallerProtocol?
    private var collectionView: UICollectionView?
    private var albums: [Album] = []
    private let artistID: String
    private let collectionViewHeaderLabel = UILabel()
    
    // MARK: - Init
    
    init(artistID: String, apiCaller: ArtistApiCallerProtocol) {
        self.artistID = artistID
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
        fetchAlbumsData()
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
    }
    
}

// MARK: - Methods

extension ArtistAlbumsViewController {
    
    private func setupVC() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        guard let collectionView = collectionView else { return }
        
        layout.scrollDirection = .horizontal
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(ReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: ReleaseCollectionViewCell.reuseID)
        
        collectionViewHeaderLabel.textAlignment = .left
        collectionViewHeaderLabel.addSeparator()
        collectionViewHeaderLabel.text = R.string.localizable.albums_title()
        collectionViewHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        view.addSubview(collectionView)
        view.addSubview(collectionViewHeaderLabel)
    }
    
    private func setupConstraints() {
        guard let collectionView = collectionView else { return }
        
        collectionViewHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(5)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.frame.width - 30)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(collectionViewHeaderLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.frame.height / 3 )
        }
    }
    
    private func fetchAlbumsData() {
        apiCaller?.getArtistAlbums(artist: artistID) { [weak self] result in
            switch result {
            case .failure(let error):
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
            case .success(let response):
                self?.albums = response.items
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension ArtistAlbumsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReleaseCollectionViewCell.reuseID,
                                                            for: indexPath) as? ReleaseCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(album: albums[indexPath.item])
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ArtistAlbumsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AppContainer.makeAlbumDetailedVC(album: albums[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ArtistAlbumsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2.5
        return CGSize(width: width, height: width + 30)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
}
