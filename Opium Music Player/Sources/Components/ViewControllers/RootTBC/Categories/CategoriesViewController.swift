//
//  CategoriesViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 06.08.2021.
//

import UIKit

// MARK: CategoriesViewController

final class CategoriesViewController: UIViewController {

    // MARK: Properties
    
    private var collectionView: UICollectionView?
    private var categories: [Category] = []
    private weak var apiCaller: APICallerProtocol?
    
    // MARK: - Init
    
    init(apiCaller: APICallerProtocol) {
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
        self.fetchData()
    }
    
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

extension CategoriesViewController {
    
    private func setupViewController() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        guard let collectionView = collectionView else { return }
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCollectionViewCell.self,
                                forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseID)
        
        view.addSubview(collectionView)

        title = R.string.localizable.categories()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.settings(),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSetting))
        navigationItem.rightBarButtonItem?.tintColor = R.color.darkLight()
        
        navigationController?.setTranslusentNavigationBar()
        AppContainer.makeAppBackgroundColor(on: self.view)
    }

    private func setupConstraints() {
        collectionView?.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
    }

    private func fetchData() {
        apiCaller?.getAllCategories { [weak self] result in
            switch result {
            case .success(let response):
                self?.categories = response.categories.items ?? []
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            case .failure(let error):
                AppContainer.showAlert(type: .failure, text: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - Actions

extension CategoriesViewController {
    
    @objc private func didTapSetting() {
        let vc = AppContainer.makeSettingsVC()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource

extension CategoriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseID,
                                                            for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(category: categories[indexPath.item])
        
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension CategoriesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AppContainer.makePlaylistsVC(category: categories[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CategoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 10
        return CGSize(width: width, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
}
