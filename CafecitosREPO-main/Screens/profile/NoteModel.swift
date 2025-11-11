//
//  NoteModel.swift
//  KaapehApp
//

import Foundation
import SwiftData

@Model
final class NoteEntity {
    var id: UUID
    var title: String
    var content: String
    var date: Date

    init(id: UUID = UUID(), title: String = "", content: String = "", date: Date = .now) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
    }
}
