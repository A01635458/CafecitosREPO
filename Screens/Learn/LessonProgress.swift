import Foundation

struct LessonProgress: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    let lesson_id: UUID
    let completed: Bool
    let created_at: Date?
    let updated_at: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case lesson_id
        case completed
        case created_at
        case updated_at
    }
}
