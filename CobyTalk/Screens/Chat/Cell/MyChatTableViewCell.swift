//
//  MyChatTableViewCell.swift
//  CobyTalk
//
//  Created by COBY_PRO on 2022/11/01.
//

import UIKit

import SnapKit
import Then

final class MyChatTableViewCell: BaseTableViewCell {
    
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
        $0.backgroundColor = .mainPink
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.preferredMaxLayoutWidth = 250
    }
    
    // MARK: - func
    
    override func render() {
        contentView.addSubviews(chatLabel, chatDateLabel)
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
            $0.height.equalTo(100)
        }
        
        chatLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(5)
        }
        
        chatDateLabel.snp.makeConstraints {
            $0.trailing.equalTo(chatLabel.snp.leading).offset(10)
            $0.top.equalToSuperview().inset(5)
        }
    }
}
