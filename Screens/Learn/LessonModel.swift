
import Foundation

struct Lesson: Identifiable, Decodable {
    let id: UUID
    let title: String
    let subtitle: String
    let content: String
    let bannerURL: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case content
        case bannerURL = "banner_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
