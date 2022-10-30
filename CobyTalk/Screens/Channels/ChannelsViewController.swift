//
//  ChannelsViewController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore
import SnapKit
import Then

final class ChannelsViewController: BaseViewController {

    private let database = Firestore.firestore()
    private var channelReference: CollectionReference {
        return database.collection("channels")
    }

    private var channels: [Channel] = []
    private var channelListener: ListenerRegistration?

    private var currentUser: User?

    deinit {
        channelListener?.remove()
    }
    
    // MARK: - property
    
    private lazy var channelTableView = UITableView().then {
        $0.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.className)
        $0.delegate = self
        $0.dataSource = self
        
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - func
    
    override func render() {
        view.addSubview(channelTableView)
        channelTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        Task { [weak self] in
            guard let user = await FirebaseManager.shared.getUser() else { return }
            self?.currentUser = user
        }
        
        channelListener = channelReference.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.leftBarButtonItem = nil
        
        title = "메세지"
    }
    
    // MARK: - Helpers

    private func addChannelToTable(_ channel: Channel) {
        if channels.contains(channel) {
            return
        }

        channels.append(channel)
        channels.sort()

        guard let index = channels.firstIndex(of: channel) else {
            return
        }
        channelTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
            return
        }

        channels[index] = channel
        channelTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    private func removeChannelFromTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
            return
        }

        channels.remove(at: index)
        channelTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else {
            return
        }

        switch change.type {
        case .added:
            addChannelToTable(channel)
        case .modified:
            updateChannelInTable(channel)
        case .removed:
            removeChannelFromTable(channel)
        }
    }
}

extension ChannelsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.className, for: indexPath) as! ChannelTableViewCell
        
        cell.selectionStyle = . none
        cell.chatUserNameLabel.text = channels[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        let viewController = ChatViewController(user: currentUser!, channel: channel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
