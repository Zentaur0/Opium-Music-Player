//
//  ReliasesViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit

private struct Constants {
    static let album = "album"
    static let single = "single"
}

// MARK: - ReleaseViewController

final class ReleaseViewController: UIViewController {

    // MARK: - Properties
    
    private var tableView: UITableView = UITableView()
    private let topview: UIView = UIView()
    private let sectionText = [R.string.localizable.albums_title(), R.string.localizable.singles_title()]
    private var newAlbums: [Album] = []
    private var newSingles: [Album] = []
    private weak var apiCaller: APICallerProtocol?

    // MARK: - Init
    
    init(apiCaller: APICallerProtocol?) {
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
        self.fetchData()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupConstraints()
    }

}

// MARK: - Methods

extension ReleaseViewController {
    
    private func setupViewController() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.register(ReleaseTableViewCell.self, forCellReuseIdentifier: ReleaseTableViewCell.reuseID)

        view.addSubview(topview)
        view.addSubview(tableView)

        title = R.string.localizable.releases()
        
        navigationController?.setTranslusentNavigationBar()
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }

    private func setupConstraints() {
        topview.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.width.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
    }
    
    private func fetchData() {
        apiCaller?.getNewReleases { [weak self] result in
            switch result {
            case .success(let response):
                for release in response.albums?.items ?? [] {
                    switch release.album_type {
                    case Constants.album: self?.newAlbums.append(release)
                    case Constants.single: self?.newSingles.append(release)
                    default: break
                    }
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension ReleaseViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionText[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReleaseTableViewCell.reuseID,
                                                       for: indexPath) as? ReleaseTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SimpleView()
        header.configure(text: sectionText[section])
        return header
    }

}

// MARK: - UITableViewDelegate

extension ReleaseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.height / 2 - 22
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ReleaseTableViewCell,
              let collection = cell.collection else { return }

        collection.delegate = self
        collection.dataSource = self
        collection.tag = indexPath.section
        collection.reloadData()
    }
    
}

// MARK: -  UICollectionViewDataSource

extension ReleaseViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0: return newAlbums.count
        default: return newSingles.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReleaseCollectionViewCell.reuseID,
                                                            for: indexPath) as? ReleaseCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        switch collectionView.tag {
        case 0:
            cell.configure(indexPath: indexPath, albums: newAlbums, singles: [])
        default:
            cell.configure(indexPath: indexPath, albums: [], singles: newSingles)
        }

        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension ReleaseViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            let album = newAlbums[indexPath.item]
            let vc = AppContainer.makeAlbumDetailedVC(album: album)
            navigationController?.pushViewController(vc, animated: true)
        } else if collectionView.tag == 1 {
            let album = newSingles[indexPath.item]
            let vc = AppContainer.makeAlbumDetailedVC(album: album)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ReleaseViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 40) / 2
        return CGSize(width: width, height: width + 24)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        15
    }

}
