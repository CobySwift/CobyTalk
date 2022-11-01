//
//  ChatTableViewCell.swift
//  CobyTalk
//
//  Created by COBY_PRO on 2022/11/01.
//

import UIKit

import SnapKit
import Then

class ChatTableViewCell: BaseTableViewCell {
    
    // MARK: - property
    
    lazy var chatUserImageView = UIImageView().then {
        let url = URL(string: "https://picsum.photos/600/600/?random")
        $0.load(url: url!)
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    lazy var chatDateLabel = UILabel().then {
        $0.textColor = .mainGray
        $0.font = UIFont.systemFont(ofSize: 11)
    }
    
    lazy var chatLastLabel = PaddingLabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.backgroundColor = .mainBlue
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    // MARK: - func
    
    override func render() {
        contentView.addSubviews(chatUserImageView, chatLastLabel)
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
            $0.height.equalTo(chatLastLabel.snp.height).offset(20)
        }
        
        chatUserImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(12)
        }
        
        chatLastLabel.snp.makeConstraints {
            $0.leading.equalTo(chatUserImageView.snp.trailing).offset(20)
            $0.top.equalToSuperview().inset(10)
        }
    }
}
