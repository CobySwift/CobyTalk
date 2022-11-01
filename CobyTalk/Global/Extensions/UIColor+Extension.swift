//
//  UIColor+Extension.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

extension UIColor {
    
    // MARK: - black

    static var mainBlack: UIColor {
        return UIColor(hex: "#182629")
    }
    
    // MARK: - gray

    static var mainGray: UIColor {
        return UIColor(hex: "#999999")
    }
    
    static var gray001: UIColor {
        return UIColor(hex: "#DDDDDD")
    }
    
    // MARK: - pink
    
    static var mainPink: UIColor {
        return UIColor(hex: "#FF9DA4")
    }
    
    // MARK: - blue
    
    static var mainBlue: UIColor {
        return UIColor(hex: "#B4CDDB")
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}
