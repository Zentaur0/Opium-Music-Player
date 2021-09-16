//
//  SearchResultController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 05.09.2021.
//

import UIKit

// MARK: - SearchResultViewControllerDelegate

protocol SearchResultViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

// MARK: - SearchResultViewController

final class SearchResultViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: SearchResultViewControllerDelegate?
    private var sections: [SearchSectionViewModel] = []
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupConstraints()
    }
    
}

// MARK: - Methods

extension SearchResultViewController {
    
    func update(with results: [SearchResult]) {
        let artists = results.filter {
            switch $0 {
            case .artist: return true
            default: return false
            }
        }
        
        let albums = results.filter {
            switch $0 {
            case .album: return true
            default: return false
            }
        }
        
        let tracks = results.filter {
            switch $0 {
            case .track: return true
            default: return false
            }
        }
        
        let playlists = results.filter {
            switch $0 {
            case .playlist: return true
            default: return false
            }
        }
        
        self.sections = [
            SearchSectionViewModel(title: R.string.localizable.search_song_section(), results: tracks),
            SearchSectionViewModel(title: R.string.localizable.search_artist_section(), results: artists),
            SearchSectionViewModel(title: R.string.localizable.search_playlist_section(), results: playlists),
            SearchSectionViewModel(title: R.string.localizable.search_album_section(), results: albums)
        ]
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    private func setupVC() {
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.reuseID)
        
        view.backgroundColor = .clear
        view.addSubview(tableView)
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

// MARK: - UITableViewDataSource

extension SearchResultViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.reuseID,
                                                       for: indexPath) as? SongCell else {
            return UITableViewCell()
        }
        
        let result = sections[indexPath.section].results[indexPath.row]
        
        switch result {
        case .artist(model: let artist):
            let model = DetailedViewModel(name: artist.name,
                                          artistName: nil,
                                          image: URL(string: artist.images?.first?.url ?? ""))
            
            cell.configureCell(viewModel: model)
        case .album(model: let album):
            let model = DetailedViewModel(name: album.name,
                                          artistName: album.artists.first?.name ?? "",
                                          image: URL(string: album.images?.first?.url ?? ""))
            
            cell.configureCell(viewModel: model)
        case .track(model: let track):
            let model = DetailedViewModel(name: track.name,
                                          artistName: track.artists?.first?.name,
                                          image: URL(string: track.album?.images?.first?.url ?? ""))
            
            cell.configureCell(viewModel: model)
        case .playlist(model: let playlist):
            let model = DetailedViewModel(name: playlist.name,
                                          artistName: nil,
                                          image: URL(string: playlist.images.first?.url ?? ""))
            
            cell.configureCell(viewModel: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
}

// MARK: - UITableViewDelegate

extension SearchResultViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = sections[indexPath.section].results[indexPath.row]
        
        delegate?.didTapResult(result)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
