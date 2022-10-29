//
//  UIView+Additions.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

extension UIView {
    func smoothRoundCorners(to radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: radius
        ).cgPath
        
        layer.mask = maskLayer
    }
}
