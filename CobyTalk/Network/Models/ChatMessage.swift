//
//  ChatMessage.swift
//  CobyTalk
//
//  Created by Coby Kim on 2022/10/30.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
