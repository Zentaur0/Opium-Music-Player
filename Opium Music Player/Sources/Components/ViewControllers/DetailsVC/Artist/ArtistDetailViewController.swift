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
    
    weak var apiCaller: ArtistApiCallerProtocol?
    private let artistID: String
    private let artistTrackVC: ArtistTracksViewController
    private let artistAlbumsVC: ArtistAlbumsViewController
    private let artistImageView = UIImageView()
    private let artistImageBackView = UIView()
    private let artistNameLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - Init
    
    init(artistID: String, apiCaller: ArtistApiCallerProtocol) {
        self.artistID = artistID
        self.apiCaller = apiCaller
        self.artistTrackVC = ArtistTracksViewController(artistID: artistID, apiCaller: apiCaller)
        self.artistAlbumsVC = ArtistAlbumsViewController(artistID: artistID, apiCaller: apiCaller)
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
        addChildren()
        setupConstraints()
    }
    
}

// MARK: - Methods

extension ArtistDetailViewController {
    
    private func addChildren() {
        addChild(artistAlbumsVC)
        contentView.addSubview(artistAlbumsVC.view)
        artistAlbumsVC.didMove(toParent: self)
        
        addChild(artistTrackVC)
        contentView.addSubview(artistTrackVC.view)
        artistTrackVC.didMove(toParent: self)
    }
    
    private func setupVC() {
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
    
    private func setupConstraints() {
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
        
        artistAlbumsVC.view.snp.makeConstraints {
            $0.top.equalTo(artistNameLabel.snp.bottom).offset(5)
            let height = view.frame.height / 3 + 30 + 5 // collection + label + inset
            $0.height.equalTo(height)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(artistTrackVC.view.snp.top).offset(-20)
        }
        
        artistTrackVC.view.snp.makeConstraints {
            $0.height.equalTo(scrollView.snp.height).offset(40)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func fetchData() {
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
