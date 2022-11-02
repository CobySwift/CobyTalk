//
//  ViewController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore
import SnapKit
import Then

final class ChatViewController: BaseViewController {
    
    private var name: String
    private var fromId: String
    private var toId: String
    
    private var chatMessages = [ChatMessage]()
    
    private var currentUser: User?
    private var chatUser: User?
    
    private var firestoreListener: ListenerRegistration?
    
    init(name: String, fromId: String, toId: String) {
        self.name = name
        self.fromId = fromId
        self.toId = toId
        super.init(nibName: nil, bundle: nil)
        
        title = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var chatTableView = UITableView().then {
        $0.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.className)
        $0.register(MyChatTableViewCell.self, forCellReuseIdentifier: MyChatTableViewCell.className)
        $0.delegate = self
        $0.dataSource = self
        
        $0.separatorStyle = .none
    }
    
    private lazy var chatSendView = ChatSendView().then {
        $0.chatSendbutton.addTarget(self, action: #selector(didTapChatSendbutton), for: .touchUpInside)
    }
    
    override func render() {
        view.addSubviews(chatSendView, chatTableView)
        
        chatSendView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        chatTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(chatSendView.snp.top).offset(-10)
        }
        
        Task { [weak self] in
            self?.currentUser = await FirebaseManager.shared.getUser()
            self?.chatUser = await FirebaseManager.shared.getUserWithId(id: toId)
        }
        
        getChatMessages()
    }
    
    private func getChatMessages() {
        let firestoreReference = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
        
        firestoreListener = firestoreReference.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            guard let snapshot = querySnapshot else {
                print("Error listening for ChatMessages: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    private func addChatMessageToTable(_ chatMessage: ChatMessage) {
        let docId = chatMessage.id
        if chatMessages.contains(where: { rm in
            return rm.id == docId
        }) {
            return
        }
        
        chatMessages.append(chatMessage)
        
        guard let index = chatMessages.firstIndex(where: { rm in
            return rm.id == docId
        }) else {
            return
        }
        chatTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChatMessageInTable(_ chatMessage: ChatMessage) {
        let docId = chatMessage.id
        guard let index = chatMessages.firstIndex(where: { rm in
            return rm.id == docId
        }) else {
            return
        }
        
        chatMessages[index] = chatMessage
        chatTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChatMessageFromTable(_ chatMessage: ChatMessage) {
        let docId = chatMessage.id
        guard let index = chatMessages.firstIndex(where: { rm in
            return rm.id == docId
        }) else {
            return
        }
        
        chatMessages.remove(at: index)
        chatTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let chatMessage = try? change.document.data(as: ChatMessage.self) else {
            return
        }
        
        switch change.type {
        case .added:
            addChatMessageToTable(chatMessage)
        case .modified:
            updateChatMessageInTable(chatMessage)
        case .removed:
            removeChatMessageFromTable(chatMessage)
        }
        
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatMessages.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func isFirstChat(index: Int) -> Bool {
        if index == 0 { return true }
        if chatMessages[index].fromId != chatMessages[index - 1].fromId { return true }
        return false
    }
    
    @objc private func didTapChatSendbutton() {
        guard let currentUser = currentUser, let chatUser = chatUser else { return }
        guard chatSendView.chatTextField.text != "", let chatText = chatSendView.chatTextField.text else { return }
        
        FirebaseManager.shared.createChatMessage(currentUser: currentUser, chatUser: chatUser, chatText: chatText)
        PushNotificationSender().sendPushNotification(to: chatUser.token, title: currentUser.name, body: chatText)
        chatSendView.chatTextField.text = ""
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chatMessages[indexPath.row].fromId == fromId {
            let cell = tableView.dequeueReusableCell(withIdentifier: MyChatTableViewCell.className, for: indexPath) as! MyChatTableViewCell
                  
            cell.chatLabel.text = chatMessages[indexPath.row].text
            
            if isFirstChat(index: indexPath.row) {
                cell.chatDateLabel.text = chatMessages[indexPath.row].timeAgo
            }
            
            cell.chatLabel.preferredMaxLayoutWidth = 250
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.className, for: indexPath) as! ChatTableViewCell
            
            cell.chatLabel.text = chatMessages[indexPath.row].text
            
            cell.chatLabel.preferredMaxLayoutWidth = 220
            cell.selectionStyle = .none
            
            if isFirstChat(index: indexPath.row) {
                guard let profileImageUrl = chatUser?.profileImageUrl else { return cell }
                cell.chatUserImageView.load(url: URL(string: profileImageUrl)!)
                cell.chatDateLabel.text = chatMessages[indexPath.row].timeAgo
            }
            
            return cell
        }
    }
}
