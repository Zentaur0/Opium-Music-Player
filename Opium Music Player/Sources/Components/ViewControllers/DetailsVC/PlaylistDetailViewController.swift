//
//  PlaylistDetailViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 07.09.2021.
//

import UIKit

// MARK: - UniversalViewController

final class PlaylistDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private let playlist: Playlist
    private var viewModels: [DetailedViewModel] = []
    private var tracks: [AudioTrack] = []
    private weak var apiCaller: SongListAPICallerProtocol?
    
    // MARK: - Init
    
    init(apiCaller: SongListAPICallerProtocol, playlist: Playlist) {
        self.apiCaller = apiCaller
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
        fetchData()
    }
    
    @available (*, unavailable)
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

extension PlaylistDetailViewController {
    
    private func setupVC() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.reuseID)
        tableView.register(AlbumHeaderView.self, forHeaderFooterViewReuseIdentifier: AlbumHeaderView.reuseID)
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setTranslusentNavigationBar()
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func fetchData() {
        apiCaller?.getPlaylistDetails(for: playlist) { [weak self] result in
            switch result {
            case .failure(let error):
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
            case .success(let playlist):
                self?.tracks = playlist.tracks?.items?.compactMap { $0.track } ?? []
                self?.viewModels = playlist.tracks?.items?.compactMap {
                    DetailedViewModel(name: $0.track?.name ?? "",
                                      artistName: $0.track?.artists?.first?.name ?? "",
                                      image: URL(string: $0.track?.album?.images?.first?.url ?? ""))
                } ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension PlaylistDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.reuseID,
                                                       for: indexPath) as? SongCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(viewModel: viewModels[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: AlbumHeaderView.reuseID)
                as? AlbumHeaderView else {
            return UIView()
        }
        
        let header = HeaderViewModel(album: playlist.name,
                                     description: playlist.description,
                                     image: playlist.images.first?.url ?? "",
                                     name: "")
        
        view.configure(with: header)
        view.delegate = self
        
        return view
    }
    
}

// MARK: - UITableViewDelegate

extension PlaylistDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let track = tracks[indexPath.row]
        
        PlayerPresenter.shared.startPlaying(track: track, tracks: tracks)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}

extension PlaylistDetailViewController: HeaderViewDelegate {
    
    func playAllButtonTapped() {
        PlayerPresenter.shared.startPlaying(tracks: self.tracks)
    }
    
}
