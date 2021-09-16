//
//  ArtistDetailViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 09.09.2021.
//

import UIKit

// MARK: - ArtistDetailViewController

final class ArtistDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var tracks: [AudioTrack] = []
    weak var apiCaller: ArtistApiCallerProtocol?
    private let artistID: String
    private let artistImageView = UIImageView()
    private let artistImageBackView = UIView()
    private let artistNameLabel = UILabel()
    private let tableView = UITableView()
    private var collectionView: UICollectionView?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let collectionViewHeaderLabel = UILabel()
    private let tableViewHeaderLabel = UILabel()
    private var albums: [Album] = []
    
    // MARK: - Init
    
    init(artistID: String, apiCaller: ArtistApiCallerProtocol) {
        self.artistID = artistID
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
        fetchData()
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

extension ArtistDetailViewController {
    
    private func setupVC() {
        setupCollectionView()
        
        setupTableView()
        
        artistNameLabel.textAlignment = .center
        artistNameLabel.font = .systemFont(ofSize: 20, weight: .medium)
        
        artistImageView.contentMode = .scaleAspectFit
        artistImageView.clipsToBounds = true
        artistImageBackView.layer.cornerRadius = view.frame.width / 2
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(artistImageBackView)
        contentView.addSubview(artistNameLabel)
        artistImageBackView.addSubview(artistImageView)
        
        navigationController?.setTranslusentNavigationBar()
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }
    
    private func setupCollectionView() {
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
        
        contentView.addSubview(collectionView)
        contentView.addSubview(collectionViewHeaderLabel)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.reuseID)
        
        tableViewHeaderLabel.textAlignment = .left
        tableViewHeaderLabel.addSeparator()
        tableViewHeaderLabel.text = R.string.localizable.top_tracks()
        tableViewHeaderLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        contentView.addSubview(tableView)
        contentView.addSubview(tableViewHeaderLabel)
    }
    
    private func setupConstraints() {
        guard let collectionView = collectionView else { return }
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
            $0.height.equalToSuperview().priority(400)
        }
        
        artistImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        artistImageBackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.width.equalTo(scrollView.snp.width)
            $0.centerX.equalToSuperview()
        }
        
        artistNameLabel.snp.makeConstraints {
            $0.top.equalTo(artistImageBackView.snp.bottom).offset(15)
            $0.width.equalTo(view.frame.width - 30)
            $0.centerX.equalToSuperview()
        }
        
        collectionViewHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(artistNameLabel.snp.bottom).offset(5)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.frame.width - 30)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(collectionViewHeaderLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.frame.height / 3 )
        }
        
        tableViewHeaderLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(10)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view.frame.width - 30)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(tableViewHeaderLabel.snp.bottom).offset(10)
            $0.height.equalTo(scrollView.snp.height)
            $0.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    private func fetchData() {
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
        
        apiCaller?.getArtist(artist: artistID) { [weak self] result in
            switch result {
            case .failure(let error):
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
            case .success(let artist):
                DispatchQueue.main.async {
                    guard let url = URL(string: artist.images?.first?.url ?? "") else { return }
                    self?.artistImageView.sd_setImage(with: url)
                    self?.artistNameLabel.text = artist.name
                }
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension ArtistDetailViewController: UICollectionViewDataSource {
    
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

extension ArtistDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AppContainer.makeAlbumDetailedVC(album: albums[indexPath.item])
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ArtistDetailViewController: UICollectionViewDelegateFlowLayout {
    
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

// MARK: - UITableViewDataSource

extension ArtistDetailViewController: UITableViewDataSource {
    
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

extension ArtistDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        PlayerPresenter.shared.startPlaying(track: tracks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
