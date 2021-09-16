//
//  SearchViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit

// MARK: - SearchViewController

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private let emptyLabel = UILabel()
    private var apiCaller: SearchAPICallerProtocol?
    private let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: AppContainer.makeSearchResultVC())
        vc.searchBar.placeholder = R.string.localizable.search_bar_placeholder()
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    // MARK: - Init
    
    init(apiCaller: SearchAPICallerProtocol? = nil) {
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
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

extension SearchViewController {
    
    private func setupViewController() {
        emptyLabel.text = R.string.localizable.empty_search_text()
        emptyLabel.numberOfLines = 0
        
        view.addSubview(emptyLabel)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        title = R.string.localizable.search()
        
        navigationController?.setTranslusentNavigationBar()
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }

    private func setupConstraints() {
        emptyLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

}

// MARK: - SearchResultViewControllerDelegate {

extension SearchViewController: SearchResultViewControllerDelegate {
    
    func didTapResult(_ result: SearchResult) {
        switch result {
        case .artist(model: let artist):
            let vc = AppContainer.makeArtistDetailedVC(artistID: artist.id)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .album(model: let album):
            let vc = AppContainer.makeAlbumDetailedVC(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .track(model: let track):
            PlayerPresenter.shared.startPlaying(track: track)
        case .playlist(model: let playlist):
            let vc = AppContainer.makePlaylistDetailedVC(playlist: playlist)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              var query = searchController.searchBar.text else { return }
        
        resultsController.delegate = self
        
        if query.contains(" ") {
            query = query.filter { $0 != " "}
        }
        
        apiCaller?.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    AppContainer.showAlert(type: .failure, text: error.localizedDescription)
                case .success(let result):
                    resultsController.update(with: result)
                }
            }
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {}
    
}
