//
//  PlaylistViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 18.08.2021.
//

import UIKit

// MARK: - PlaylistViewController

final class PlaylistsViewController: UIViewController {

    // MARK: - Property
    
    private var category: Category
    private var collectionView: UICollectionView?
    private var playlists: [Playlist] = []
    private weak var apiCaller: APICallerProtocol?
    
    // MARK: - Init
    
    init(category: Category, apiCaller: APICallerProtocol) {
        self.category = category
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
        self.fetchData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupConstraints()
    }

}

// MARK: - Methods

extension PlaylistsViewController {
    
    private func setupVC() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        guard let collectionView = collectionView else { return }
        
        title = category.name

        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ReleaseCollectionViewCell.self,
                                forCellWithReuseIdentifier: ReleaseCollectionViewCell.reuseID)
        
        view.addSubview(collectionView)
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }

    private func setupConstraints() {
        guard let collectionView = collectionView else { return }

        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    private func fetchData() {
        apiCaller?.getPlaylist(id: category.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.playlists = response.playlists?.items ?? []
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            case .failure(let error):
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension PlaylistsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        playlists.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReleaseCollectionViewCell.reuseID,
                                                            for: indexPath) as? ReleaseCollectionViewCell else {
            return UICollectionViewCell()
        }

        let playlistImage = playlists[indexPath.row]
        cell.configure(playlist: playlistImage)

        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension PlaylistsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        let vc = AppContainer.makePlaylistDetailedVC(playlist: playlist)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PlaylistsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2.5
        return CGSize(width: width, height: width + 35)
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
