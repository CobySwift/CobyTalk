//
//  ChatSendView.swift
//  CobyTalk
//
//  Created by COBY_PRO on 2022/11/01.
//

import UIKit

import SnapKit
import Then

final class ChatSendView: UIView {
    
    // MARK: - Property
    
    let chatTextField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.mainBlack,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        
        $0.autocapitalizationType = .none
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        $0.leftViewMode = .always
        $0.clipsToBounds = false
    }
    
    let chatSendbutton = SendButton()
    
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        configUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - func
    
    private func render() {
        self.addSubviews(chatTextField, chatSendbutton)
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
            $0.height.equalTo(40)
        }
        
        chatTextField.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        chatSendbutton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
    
    private func configUI() {
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.mainGray.cgColor
        self.layer.cornerRadius = 20
    }
}
