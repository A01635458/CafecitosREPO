//
//  LessonEntity.swift
//  KaapehApp
//
//  Created by Ivan Ornelas on 04/12/25.
//

import SwiftData
import Foundation
@Model
final class LessonEntity {
    @Attribute(.unique)
    var id: UUID
    
    var title: String
    var content: String
    var bannerURL: String?
    var createdAt: Date?
    
    init(lesson: Lesson) {
        self.id = lesson.id
        self.title = lesson.title
        self.content = lesson.content
        self.bannerURL = lesson.bannerURL
        self.createdAt = lesson.createdAt
    }
}
