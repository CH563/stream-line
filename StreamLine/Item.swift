//
//  Item.swift
//  StreamLine
//
//  Created by Liwen on 2025/3/11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    var eventDescription: String
    var emoji: String
    
    init(timestamp: Date = Date(), title: String = "未命名事件", eventDescription: String = "", emoji: String = "📝") {
        self.timestamp = timestamp
        self.title = title
        self.eventDescription = eventDescription
        self.emoji = emoji
    }
}
