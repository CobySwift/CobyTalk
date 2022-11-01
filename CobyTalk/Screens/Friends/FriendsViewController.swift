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
    
    private enum Size {
        static let collectionHorizontalSpacing: CGFloat = 0
        static let collectionVerticalSpacing: CGFloat = 0
        static let cellWidth: CGFloat = UIScreen.main.bounds.size.width - collectionHorizontalSpacing * 2
        static let cellHeight: CGFloat = 100
        static let collectionInset = UIEdgeInsets(top: collectionVerticalSpacing,
                                                  left: collectionHorizontalSpacing,
                                                  bottom: collectionVerticalSpacing,
                                                  right: collectionHorizontalSpacing)
    }
    
    private let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.sectionInset = Size.collectionInset
        $0.itemSize = CGSize(width: Size.cellWidth, height: Size.cellHeight)
        $0.minimumLineSpacing = 10
    }
    
    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.showsVerticalScrollIndicator = false
        $0.register(cell: FriendCollectionViewCell.self,
                                forCellWithReuseIdentifier: FriendCollectionViewCell.className)
    }
    
    override func render() {
        view.addSubview(listCollectionView)
        
        listCollectionView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        Task { [weak self] in
            self?.currentUser = await FirebaseManager.shared.getUser()
            self?.users = await FirebaseManager.shared.getUsers()
            DispatchQueue.main.async {
                self?.listCollectionView.reloadData()
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

// MARK: - UICollectionViewDataSource
extension FriendsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let users = users else { return 0 }
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FriendCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        guard let user = users?[indexPath.item] else { return cell }
        
        cell.nameLabel.text = user.name
        cell.emailLabel.text = user.email
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FriendsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUser = currentUser else { return }
        guard let chatUser = users?[indexPath.row] else { return }
        let viewController = ChatViewController(name: chatUser.name, fromId: currentUser.uid, toId: chatUser.uid)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
