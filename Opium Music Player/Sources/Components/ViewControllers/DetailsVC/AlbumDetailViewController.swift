//
//  UniversalVC.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 30.08.2021.
//

import UIKit

// MARK: - UniversalViewController

final class AlbumDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    private let album: Album
    private var viewModels: [DetailedViewModel] = []
    private var tracks: [AudioTrack] = []
    private weak var apiCaller: SongListAPICallerProtocol?
    
    // MARK: - Init
    
    init(apiCaller: SongListAPICallerProtocol, album: Album) {
        self.apiCaller = apiCaller
        self.album = album
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

extension AlbumDetailViewController {
    
    private func setupVC() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView()
        tableView.register(AlbumSongCell.self, forCellReuseIdentifier: AlbumSongCell.reuseID)
        tableView.register(AlbumHeaderView.self, forHeaderFooterViewReuseIdentifier: AlbumHeaderView.reuseID)
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        navigationItem.largeTitleDisplayMode = .never

        AppContainer.makeAppBackgroundColor(on: self.view)
        
        navigationController?.setTranslusentNavigationBar()
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func fetchData() {
        apiCaller?.getAlbumDetails(for: album) { [weak self] result in
            switch result {
            case .success(let album):
                self?.tracks = album.tracks?.items ?? []
                self?.viewModels = album.tracks?.items?.compactMap {
                    DetailedViewModel(name: $0.name,
                                      artistName: $0.artists?.first?.name ?? "",
                                      image: URL(string: ""))
                } ?? []
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

extension AlbumDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumSongCell.reuseID,
                                                       for: indexPath) as? AlbumSongCell else {
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
        
        let header = HeaderViewModel(album: album.name,
                                     description: album.release_date,
                                     image: album.images?.first?.url ?? "",
                                     name: album.artists.first?.name ?? "")
        
        view.configure(with: header)
        view.delegate = self
        view.artistDelegate = self
        
        return view
    }
    
}

// MARK: - UITableViewDelegate

extension AlbumDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var track = tracks[indexPath.row]
        
        if tracks.count > 1 {
            let tracksWithAlbum: [AudioTrack] = self.tracks.compactMap {
                var track = $0
                track.album = self.album
                return track
            }
            
            PlayerPresenter.shared.startPlaying(track: track, tracks: tracksWithAlbum)
        } else {
            track.album = self.album
            
            PlayerPresenter.shared.startPlaying(track: track)
        }  
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}

// MARK: - HeaderViewDelegate

extension AlbumDetailViewController: HeaderViewDelegate {
    
    func playAllButtonTapped() {
        let tracksWithAlbum: [AudioTrack] = self.tracks.compactMap {
            var track = $0
            track.album = self.album
            return track
        }
        
        PlayerPresenter.shared.startPlaying(tracks: tracksWithAlbum)
    }
    
}

// MARK: - HeaderArtistButtonDelegate

extension AlbumDetailViewController: HeaderAlbumViewDelegate {
    
    func openArtistPage() {
        guard let artistID = album.artists.first?.id else { return }
        let vc = AppContainer.makeArtistDetailedVC(artistID: artistID)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
