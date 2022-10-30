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
    
    // MARK: - property
    
    private lazy var channelTableView = UITableView().then {
        $0.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.className)
        $0.delegate = self
        $0.dataSource = self
        
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private var channels: [Channel]?
    private var currentUser: User?
    
    // MARK: - func
    
    override func render() {
        view.addSubview(channelTableView)
        channelTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        Task { [weak self] in
            guard let user = await FirebaseManager.shared.getUser() else { return }
            self?.currentUser = user
            self?.channels = await FirebaseManager.shared.getChannels()
            DispatchQueue.main.async {
                self?.channelTableView.reloadData()
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
}

extension ChannelsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard channels != nil else { return 0 }
        return channels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.className, for: indexPath) as! ChannelTableViewCell
        
        guard channels != nil else { return cell }
        
        cell.selectionStyle = . none
        cell.chatUserNameLabel.text = channels?[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard channels != nil else { return }
        let channel = channels?[indexPath.row]
        let viewController = ChatViewController(user: currentUser!, channel: channel!)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}


//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//final class ChannelsViewController: UITableViewController {
//    private let toolbarLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 15)
//        return label
//    }()
//
//    private let channelCellIdentifier = "channelCell"
//    private var currentChannelAlertController: UIAlertController?
//
//    private let database = Firestore.firestore()
//    private var channelReference: CollectionReference {
//        return database.collection("channels")
//    }
//
//    private var channels: [Channel] = []
//    private var channelListener: ListenerRegistration?
//
//    private let currentUserId: String
//
//    deinit {
//        channelListener?.remove()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        clearsSelectionOnViewWillAppear = true
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
//
//        toolbarItems = [
//            UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(customView: toolbarLabel),
//            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
//            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
//        ]
//        toolbarLabel.text = AppSettings.displayName
//
//        channelListener = channelReference.addSnapshotListener { [weak self] querySnapshot, error in
//            guard let self = self else { return }
//            guard let snapshot = querySnapshot else {
//                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
//                return
//            }
//
//            snapshot.documentChanges.forEach { change in
//                self.handleDocumentChange(change)
//            }
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.isToolbarHidden = false
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.isToolbarHidden = true
//    }
//
//    // MARK: - Actions
//    @objc private func signOut() {
//        let alertController = UIAlertController(
//            title: nil,
//            message: "Are you sure you want to sign out?",
//            preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        alertController.addAction(cancelAction)
//
//        let signOutAction = UIAlertAction(
//            title: "Sign Out",
//            style: .destructive) { _ in
//                do {
//                    try Auth.auth().signOut()
//                } catch {
//                    print("Error signing out: \(error.localizedDescription)")
//                }
//            }
//        alertController.addAction(signOutAction)
//
//        present(alertController, animated: true)
//    }
//
//    @objc private func addButtonPressed() {
//        let alertController = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alertController.addTextField { field in
//            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//            field.enablesReturnKeyAutomatically = true
//            field.autocapitalizationType = .words
//            field.clearButtonMode = .whileEditing
//            field.placeholder = "Channel name"
//            field.returnKeyType = .done
//            field.tintColor = .black
//        }
//
//        let createAction = UIAlertAction(
//            title: "Create",
//            style: .default) { _ in
//                self.createChannel()
//            }
//        createAction.isEnabled = false
//        alertController.addAction(createAction)
//        alertController.preferredAction = createAction
//
//        present(alertController, animated: true) {
//            alertController.textFields?.first?.becomeFirstResponder()
//        }
//        currentChannelAlertController = alertController
//    }
//
//    @objc private func textFieldDidChange(_ field: UITextField) {
//        guard let alertController = currentChannelAlertController else {
//            return
//        }
//        alertController.preferredAction?.isEnabled = field.hasText
//    }
//
//    // MARK: - Helpers
//    private func createChannel() {
//        guard
//            let alertController = currentChannelAlertController,
//            let channelName = alertController.textFields?.first?.text
//        else {
//            return
//        }
//
//        let channel = Channel(name: channelName)
//        channelReference.addDocument(data: channel.representation) { error in
//            if let error = error {
//                print("Error saving channel: \(error.localizedDescription)")
//            }
//        }
//    }
//
//    private func addChannelToTable(_ channel: Channel) {
//        if channels.contains(channel) {
//            return
//        }
//
//        channels.append(channel)
//        channels.sort()
//
//        guard let index = channels.firstIndex(of: channel) else {
//            return
//        }
//        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//    }
//
//    private func updateChannelInTable(_ channel: Channel) {
//        guard let index = channels.firstIndex(of: channel) else {
//            return
//        }
//
//        channels[index] = channel
//        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//    }
//
//    private func removeChannelFromTable(_ channel: Channel) {
//        guard let index = channels.firstIndex(of: channel) else {
//            return
//        }
//
//        channels.remove(at: index)
//        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//    }
//
//    private func handleDocumentChange(_ change: DocumentChange) {
//        guard let channel = Channel(document: change.document) else {
//            return
//        }
//
//        switch change.type {
//        case .added:
//            addChannelToTable(channel)
//        case .modified:
//            updateChannelInTable(channel)
//        case .removed:
//            removeChannelFromTable(channel)
//        }
//    }
//}
//
//// MARK: - TableViewDelegate
//extension ChannelsViewController {
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return channels.count
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 55
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath)
//        cell.accessoryType = .disclosureIndicator
//        cell.textLabel?.text = channels[indexPath.row].name
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let channel = channels[indexPath.row]
//        let viewController = ChatViewController(user: currentUser!, channel: channel)
//        navigationController?.pushViewController(viewController, animated: true)
//    }
//}
