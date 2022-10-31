//
//  ChannelsViewController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import SnapKit
import Then

final class ChannelsViewController: BaseViewController {
    
    private var currentUser: User?
    private var recentMessages: [RecentMessage]?
    
    // MARK: - property
    
    private lazy var channelTableView = UITableView().then {
        $0.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.className)
        $0.delegate = self
        $0.dataSource = self
        
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private lazy var addButton = AddButton().then {
        $0.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    // MARK: - func
    
    override func render() {
        view.addSubview(channelTableView)
        
        channelTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        Task { [weak self] in
            self?.currentUser = await FirebaseManager.shared.getUser()
            self?.recentMessages = await FirebaseManager.shared.getRecentMessages()
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()

        let addButton = makeBarButtonItem(with: addButton)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = addButton
        
        title = "메세지"
    }
    
    @objc private func didTapAddButton() {
        let viewController = FriendsViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ChannelsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recentMessages = recentMessages else { return 0 }
        return recentMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.className, for: indexPath) as! ChannelTableViewCell
        
        cell.selectionStyle = . none
        
        guard let recentMessages = recentMessages else { return cell }
        cell.chatUserNameLabel.text = recentMessages[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ChatViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
