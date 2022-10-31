//
//  FriendCollectionViewCell.swift
//  CobyTalk
//
//  Created by COBY_PRO on 2022/10/31.
//

import UIKit

import SnapKit
import Then

final class FriendCollectionViewCell: BaseCollectionViewCell {
    
    // MARK: - property
    
    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        $0.textColor = .black
    }
    
    let emailLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .gray
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        
        return layoutAttributes
    }
    
    override func render() {
        contentView.addSubviews(nameLabel, emailLabel)
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(20)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
        }
    }
    
    override func configUI() {
        clipsToBounds = true
        makeBorderLayer(color: .white.withAlphaComponent(0.5))
    }
}
