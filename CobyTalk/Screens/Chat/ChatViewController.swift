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
    
    private var chatText = ""
    private var errorMessage = ""
    private var count = 0
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
    
    private let chatTextField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.mainBlack,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        $0.leftViewMode = .always
        $0.clipsToBounds = false
        $0.makeShadow(color: .black, opacity: 0.08, offset: CGSize(width: 0, height: 4), radius: 20)
    }
    
    private lazy var chatSendbutton = UIButton().then {
        $0.backgroundColor = .mainBlack
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Send", for: .normal)
        $0.addTarget(self, action: #selector(didTapChatSendbutton), for: .touchUpInside)
    }
    
    override func render() {
        view.addSubviews(chatTextField, chatSendbutton)
        
        chatTextField.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.trailing.equalTo(chatSendbutton.snp.leading)
            $0.height.equalTo(40)
        }
        
        chatSendbutton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.width.height.equalTo(40)
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
//        channelTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func updateChatMessageInTable(_ chatMessage: ChatMessage) {
        let docId = chatMessage.id
        guard let index = chatMessages.firstIndex(where: { rm in
            return rm.id == docId
        }) else {
            return
        }
        
        chatMessages[index] = chatMessage
//        channelTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChatMessageFromTable(_ chatMessage: ChatMessage) {
        let docId = chatMessage.id
        guard let index = chatMessages.firstIndex(where: { rm in
            return rm.id == docId
        }) else {
            return
        }
        
        chatMessages.remove(at: index)
//        channelTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
    }
    
    @objc private func didTapChatSendbutton() {
        guard let currentUser = currentUser, let chatUser = chatUser, let chatText = chatTextField.text else { return }
        FirebaseManager.shared.createChatMessage(currentUser: currentUser, chatUser: chatUser, chatText: chatText)
        PushNotificationSender().sendPushNotification(to: chatUser.token, title: currentUser.name, body: chatText)
        chatTextField.text = ""
    }
}
