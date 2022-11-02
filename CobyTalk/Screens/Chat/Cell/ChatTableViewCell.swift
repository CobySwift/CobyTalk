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
    
    var chatLabel = PaddingLabel().then {
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.backgroundColor = .mainBlue
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    // MARK: - func
    
    override func render() {
        contentView.addSubviews(chatUserImageView, chatLabel, chatDateLabel)
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
            $0.bottom.equalTo(chatLabel.snp.bottom)
        }
        
        chatUserImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(8)
        }
        
        chatLabel.snp.makeConstraints {
            $0.leading.equalTo(chatUserImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().inset(5)
        }
        
        chatDateLabel.snp.makeConstraints {
            $0.leading.equalTo(chatLabel.snp.trailing).offset(10)
            $0.top.equalToSuperview().inset(10)
        }
    }
}
