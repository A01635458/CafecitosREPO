import Vapor

// MARK: - Module DTO
struct ModuleDTO: Content {
    let id: UUID
    let title: String
    let description: String?
    let sort_order: Int
    let is_active: Bool
    let created_at: Date?
}

// MARK: - Create Module DTO
struct CreateModuleDTO: Content {
    let title: String
    let description: String?
    let sort_order: Int?
    let is_active: Bool?
}

// MARK: - Update Module DTO
struct UpdateModuleDTO: Content {
    let title: String?
    let description: String?
    let sort_order: Int?
    let is_active: Bool?
}

// MARK: - Lesson DTO
struct LessonDTO: Content {
    let id: UUID
    let module_id: UUID
    let title: String
    let content_url: String?
    let sort_order: Int
    let is_active: Bool
    let created_at: Date?
}

// MARK: - Create Lesson DTO
struct CreateLessonDTO: Content {
    let module_id: UUID
    let title: String
    let content_url: String?
    let sort_order: Int?
    let is_active: Bool?
}

// MARK: - Update Lesson DTO
struct UpdateLessonDTO: Content {
    let title: String?
    let content_url: String?
    let sort_order: Int?
    let is_active: Bool?
}

// MARK: - User DTO
struct UserDTO: Content {
    let id: UUID
    let name: String
    let email: String
    let description: String?
    let created_at: Date?
}

// MARK: - Photo DTO
struct PhotoDTO: Content {
    let id: UUID
    let user_id: UUID
    let url: String
    let storage_key: String?
    let caption: String?
    let metadata: String?
    let taken_at: Date?
    let visibility: String
    let created_at: Date?
}

// MARK: - Note DTO
struct NoteDTO: Content {
    let id: UUID
    let user_id: UUID
    let module_id: UUID?
    let lesson_id: UUID?
    let photo_id: UUID?
    let title: String?
    let body: String
    let created_at: Date?
    let updated_at: Date?
}

// MARK: - UserLessonProgress DTO
struct UserLessonProgressDTO: Content {
    let user_id: UUID
    let lesson_id: UUID
    let status: String
    let started_at: Date?
    let completed_at: Date?
    let score: Double?
}
