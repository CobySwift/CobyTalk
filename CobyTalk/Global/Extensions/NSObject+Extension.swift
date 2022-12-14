//
//  NSObject+Extension.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
