//
//  ArtistTracksViewController.swift
//  Opium Music Player
//
//  Created by Антон Сивцов on 23.09.2021.
//

import UIKit

// MARK: - ArtistTracksViewController

final class ArtistTracksViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var apiCaller: ArtistApiCallerProtocol?
    private let artistID: String
    private var tracks: [AudioTrack] = []
    private let tableView = UITableView()
    private let tableViewHeaderLabel = UILabel()
    
    // MARK: - Init
    
    init(artistID: String, apiCaller: ArtistApiCallerProtocol) {
        self.artistID = artistID
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
        fetchTracksData()
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

extension ArtistTracksViewController {
    
    private func setupVC() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.reuseID)
        
        tableViewHeaderLabel.textAlignment = .left
        tableViewHeaderLabel.addSeparator()
        tableViewHeaderLabel.text = R.string.localizable.top_tracks()
        tableViewHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        view.addSubview(tableView)
        view.addSubview(tableViewHeaderLabel)
    }
    
    private func setupConstraints() {
        tableViewHeaderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.bounds.size.width - 30)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(tableViewHeaderLabel.snp.bottom).offset(10)
            let height = view.frame.height + 30 + 5 // tableView + label + inset
            $0.height.equalTo(height)
            $0.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    private func fetchTracksData() {
        apiCaller?.getArtistTracks(artist: artistID) { [weak self] result in
            switch result {
            case .failure(let error):
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
            case .success(let response):
                DispatchQueue.main.async {
                    self?.tracks = response.tracks
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ArtistTracksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.reuseID,
                                                       for: indexPath) as? SongCell else {
            return UITableViewCell()
        }
        
        let viewModel = DetailedViewModel(
            name: tracks[indexPath.row].name,
            artistName: nil,
            image: URL(string: tracks[indexPath.row].album?.images?.first?.url ?? "")
        )
        
        cell.configureCell(viewModel: viewModel)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ArtistTracksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        PlayerPresenter.shared.startPlaying(track: tracks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
