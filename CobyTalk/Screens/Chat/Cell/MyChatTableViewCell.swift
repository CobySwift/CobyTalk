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
    
    lazy var chatUserImageView = UIImageView().then {
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    lazy var chatDateLabel = UILabel().then {
        $0.textColor = .mainGray
        $0.font = UIFont.systemFont(ofSize: 11)
    }
    
    lazy var chatLastLabel = PaddingLabel().then {
        $0.numberOfLines = 0
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.backgroundColor = .mainPink
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    // MARK: - func
    
    override func render() {
        contentView.addSubviews(chatLastLabel, chatDateLabel)
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
            $0.height.equalTo(chatLastLabel.snp.height).offset(10)
        }
        
        chatLastLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(10)
            $0.width.lessThanOrEqualTo(250)
        }
        
        chatDateLabel.snp.makeConstraints {
            $0.trailing.equalTo(chatLastLabel.snp.leading).offset(10)
            $0.top.equalToSuperview().inset(10)
        }
    }
}
