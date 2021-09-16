//
//  SettingsViewController.swift
//  Opium ~ Music Player for IPhone
//
//  Created by Антон Сивцов on 03.09.2021.
//

import UIKit

// MARK: - SettingsViewController

final class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var sections = [SectionSettingsViewModel]()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        setupVC()
        setupConstraints()
    }
    
}

// MARK: - Methods

extension SettingsViewController {
    
    private func setupVC() {
        title = R.string.localizable.settings_title()
        AppContainer.makeAppBackgroundColor(on: self.view)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureModels() {
        sections.append(SectionSettingsViewModel(
                            title: R.string.localizable.profile_title(),
                            options: [SetcionOptionSettingsViewModel(
                                title: R.string.localizable.view_profile()
                            ) { [weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
        }]))
        sections.append(SectionSettingsViewModel(
                            title: R.string.localizable.account_title(),
                            options: [SetcionOptionSettingsViewModel(
                                title: R.string.localizable.sign_out()
                            ) { [weak self] in
            DispatchQueue.main.async {
                self?.sightOutTapped()
            }
        }]))
    }
    
    private func sightOutTapped() {
        let alert = UIAlertController(title: R.string.localizable.sign_out(),
                                      message: R.string.localizable.sign_out_text(),
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel_title(), style: .cancel)
        let signOutAction = UIAlertAction(title: R.string.localizable.sign_out(), style: .destructive) { _ in
            AuthentificationManager.shared.signOut { [weak self] signedOut in
                if signedOut {
                    DispatchQueue.main.async {
                        AppContainer.showAlert(type: .success, text: R.string.localizable.success_sign_out())
                        let vc = AppContainer.makeRootVC()
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: true) {
                            self?.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(signOutAction)
        present(alert, animated: true)
    }
    
    private func viewProfile() {
        let vc = AppContainer.makeProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let model = sections[indexPath.section].options[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        
        return model.title
    }
    
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
}
