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
            self?.chatMessages = await FirebaseManager.shared.getChatMessages(fromId: fromId, toId: toId)
        }
    }
    
    @objc private func didTapChatSendbutton() {
        guard let currentUser = currentUser, let chatUser = chatUser, let chatText = chatTextField.text else { return }
        FirebaseManager.shared.createChatMessage(currentUser: currentUser, chatUser: chatUser, chatText: chatText)
        chatTextField.text = ""
    }
}
