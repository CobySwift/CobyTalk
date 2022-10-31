//
//  ViewController.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

final class ChatViewController: BaseViewController {
    
    private var name: String
    private var fromId: String
    private var toId: String
    
    private var chatText = ""
    private var errorMessage = ""
    private var count = 0
    private var chatMessages: [ChatMessage]?
    
    private var currentUser: User?
    private var chatUser: User?
    
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
    
    override func render() {
        Task { [weak self] in
            self?.currentUser = await FirebaseManager.shared.getUser()
            self?.chatUser = await FirebaseManager.shared.getUserWithId(id: toId)
            self?.chatMessages = await FirebaseManager.shared.getChatMessages(fromId: fromId, toId: toId)
        }
    }
}
