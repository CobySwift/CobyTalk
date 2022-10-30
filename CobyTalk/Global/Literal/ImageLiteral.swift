//
//  ImageLiteral.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import UIKit

enum ImageLiteral {
    
    // MARK: - button
    
    static var btnMain: UIImage { .load(systemName: "house") }
    static var btnSearch: UIImage { .load(systemName: "magnifyingglass") }
    static var btnMessage: UIImage { .load(systemName: "message") }
    static var btnProfile: UIImage { .load(systemName: "person.crop.circle") }
    static var btnBack: UIImage { .load(systemName: "chevron.backward") }

    static var btnFoward: UIImage { .load(systemName: "chevron.forward") }
    static var btnCamera: UIImage { .load(systemName: "camera") }
    static var btnSend: UIImage { .load(systemName: "paperplane") }
}
