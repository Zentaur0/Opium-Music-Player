//
//  File.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 03.09.2021.
//

import UIKit
import SDWebImage

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private weak var apiCaller: UserAPICallerProtocol?
    private var models = [String]()
    private let tableView = UITableView()
    private let headerView = UIView()
    private let headerImageView = UIImageView()
    
    // MARK: - Init
    
    init(apiCaller: UserAPICallerProtocol) {
        self.apiCaller = apiCaller
        super.init(nibName: nil, bundle: nil)
        self.fetchProfile()
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

extension ProfileViewController {
    
    private func setupVC() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        
        title = R.string.localizable.profile_title()
        
        view.addSubview(tableView)
        headerView.addSubview(headerImageView)
        
        AppContainer.makeAppBackgroundColor(on: self.view)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        headerImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(200)
        }
    }
    
    private func fetchProfile() {
        apiCaller?.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    DispatchQueue.main.async {
                        self?.updateUI(with: model)
                    }
                case .failure(let error):
                    AppContainer.showAlert(type: .failure, text: error.localizedDescription)
                    self?.failedToGetProfile()
                }
            }
        }
    }
    
    private func updateUI(with model: UserProfile) {
        tableView.isHidden = false
        models.append("\(R.string.localizable.full_name_field())\(model.display_name)")
        models.append("\(R.string.localizable.email_field())\(model.email)")
        models.append("\(R.string.localizable.id_field())\(model.id)")
        models.append("\(R.string.localizable.subscription_field())\(model.product)")
        setupTableHeader(with: model.images.first?.url)
        tableView.reloadData()
    }
    
    private func  setupTableHeader(with string: String?) {
        guard let urlString = string,
              let url = URL(string: urlString) else { return }
        
        
        headerImageView.sd_setImage(with: url, completed: nil)
        headerImageView.contentMode = .scaleAspectFill
        
        headerImageView.layer.masksToBounds = true
        headerImageView.layer.cornerRadius = 100
    }
    
    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = R.string.localizable.profile_error()
        label.sizeToFit()
        label.textColor = .black
        view.addSubview(label)
        label.center = view.center
    }
    
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.text = models[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        200
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {}
