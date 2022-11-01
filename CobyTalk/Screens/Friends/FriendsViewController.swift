//
//  FriendsViewController.swift
//  CobyTalk
//
//  Created by COBY_PRO on 2022/10/31.
//

import UIKit

import SnapKit
import Then

final class FriendsViewController: BaseViewController {
    
    private var currentUser: User?
    private var users: [User]? = []
    
    private lazy var friendTableViewCell = UITableView().then {
        $0.register(FriendTableViewCell.self, forCellReuseIdentifier: FriendTableViewCell.className)
        $0.delegate = self
        $0.dataSource = self
        
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func render() {
        view.addSubview(friendTableViewCell)
        
        friendTableViewCell.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        Task { [weak self] in
            self?.currentUser = await FirebaseManager.shared.getUser()
            self?.users = await FirebaseManager.shared.getUsers()
            DispatchQueue.main.async {
                self?.friendTableViewCell.reloadData()
            }
        }
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .automatic
        
        title = "친구 찾기"
    }
}

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let users = users else { return 0 }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendTableViewCell.className, for: indexPath) as! FriendTableViewCell
        
        cell.selectionStyle = .none
        
        guard let user = users?[indexPath.item] else { return cell }
        
        cell.nameLabel.text = user.name
        cell.emailLabel.text = user.email
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }
        guard let chatUser = users?[indexPath.row] else { return }
        let viewController = ChatViewController(name: chatUser.name, fromId: currentUser.uid, toId: chatUser.uid)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

