//
//  FriendTableViewCell.swift
//  CobyTalk
//
//  Created by COBY_PRO on 2022/10/31.
//

import UIKit

import SnapKit
import Then

final class FriendTableViewCell: BaseTableViewCell {
    
    // MARK: - property
    
    lazy var userImageView = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    lazy var nameLabel = UILabel().then {
        $0.textColor = .mainBlack
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    }
    
    lazy var emailLabel = UILabel().then {
        $0.textColor = .mainGray
        $0.font = UIFont.systemFont(ofSize: 13)
    }
    
    // MARK: - func
    
    override func render() {
        contentView.addSubviews(userImageView, nameLabel, emailLabel)
        
        userImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(20)
            $0.top.equalToSuperview().inset(14)
        }
        
        emailLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(20)
            $0.bottom.equalToSuperview().inset(14)
        }
    }
}
