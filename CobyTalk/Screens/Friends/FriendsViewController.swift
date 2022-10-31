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
    
    private var user: User?
    private var users: [User]? = []
    private var filteredUsers: [User]? = []
    private var friendIds: [String]? = []
    
    private var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
    
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
        $0.showsVerticalScrollIndicator = false
        $0.register(cell: FriendCollectionViewCell.self,
                                forCellWithReuseIdentifier: FriendCollectionViewCell.className)
    }
    
    private lazy var closeButton = CloseButton().then {
        $0.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task { [weak self] in
            self?.user = await FirebaseManager.shared.getUser()
            self?.users = await FirebaseManager.shared.getUsers()
            DispatchQueue.main.async {
                self?.listCollectionView.reloadData()
            }
        }
    }
    
    override func render() {
        view.addSubview(listCollectionView)
        
        listCollectionView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        
        let closeButton = makeBarButtonItem(with: closeButton)
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.searchResultsUpdater = self
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = closeButton
        navigationItem.searchController = searchController
        title = "친구 찾기"
    }
    
    @objc private func didTapCloseButton() {
        NotificationCenter.default.post(name: Notification.Name("willDissmiss"), object: nil)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension FriendsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let filteredUsersCount = filteredUsers?.count, let usersCount = users?.count else {
            return 0
        }
        
        return self.isFiltering ? filteredUsersCount : usersCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FriendCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        var newUser: User
        if self.isFiltering {
            guard let filteredUser = filteredUsers?[indexPath.item] else { return cell }
            newUser = filteredUser
        } else {
            guard let allUser = users?[indexPath.item] else { return cell }
            newUser = allUser
        }
        cell.nameLabel.text = newUser.name
        cell.emailLabel.text = newUser.email
        
        if (friendIds!.contains(newUser.uid)) {
            cell.addButton.setTitle("완료", for: .normal)
            cell.addButton.backgroundColor = .black
        } else {
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: #selector(didTapAddButton(sender:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    @objc private func didTapAddButton(sender: UIButton) {
        sender.showAnimation {}
        var friend: User
        if self.isFiltering {
            guard let filteredUser = filteredUsers?[sender.tag] else { return }
            friend = filteredUser
        } else {
            guard let allUser = users?[sender.tag] else { return }
            friend = allUser
        }
    }
}

extension FriendsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        self.filteredUsers! = self.users!.filter { $0.name.lowercased().contains(text) }
        self.listCollectionView.reloadData()
    }
}
