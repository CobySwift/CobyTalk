//
//  ChatTableViewCell.swift
//  CobyTalk
//
//  Created by COBY_PRO on 2022/11/01.
//

import UIKit

import SnapKit
import Then

final class ChatTableViewCell: BaseTableViewCell {
    
    // MARK: - property
    
    var chatUserImageView = UIImageView().then {
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    var chatDateLabel = UILabel().then {
        $0.textColor = .mainGray
        $0.font = UIFont.systemFont(ofSize: 11)
    }
    
    var chatLastLabel = PaddingLabel().then {
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.backgroundColor = .mainBlue
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.preferredMaxLayoutWidth = 250
    }
    
    // MARK: - func
    
    override func render() {
        contentView.addSubviews(chatUserImageView, chatLastLabel, chatDateLabel)
        
        chatUserImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(8)
        }
        
        chatLastLabel.snp.makeConstraints {
            $0.leading.equalTo(chatUserImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().inset(5)
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
            $0.bottom.equalTo(chatLastLabel.snp.bottom)
        }
        
        chatDateLabel.snp.makeConstraints {
            $0.leading.equalTo(chatLastLabel.snp.trailing).offset(10)
            $0.top.equalToSuperview().inset(5)
        }
    }
}
