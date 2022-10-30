//
//  BackButton.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

final class BackButton: UIButton {

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 44, height: 44)))
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - func
    
    private func configUI() {
        self.setImage(ImageLiteral.btnBack, for: .normal)
        self.tintColor = .mainBlack
    }
}
