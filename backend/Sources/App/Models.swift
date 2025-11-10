import Vapor
import Fluent

// MARK: - User Model
final class User: Model, Content {
    static let schema = "users"
    
    @ID(custom: "id", generatedBy: .user)
    var id: String?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Children(for: \.$user)
    var photos: [Photo]
    
    @Children(for: \.$user)
    var notes: [Note]
    
    init() { }
    
    init(id: String? = nil, name: String, email: String, description: String? = nil) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.email = email
        self.description = description
    }
}

// MARK: - Photo Model
final class Photo: Model, Content {
    static let schema = "photos"
    
    @ID(custom: "id", generatedBy: .user)
    var id: String?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "url")
    var url: String
    
    @OptionalField(key: "storage_key")
    var storageKey: String?
    
    @OptionalField(key: "caption")
    var caption: String?
    
    @OptionalField(key: "metadata")
    var metadata: String?
    
    @OptionalField(key: "taken_at")
    var takenAt: Date?
    
    @Enum(key: "visibility")
    var visibility: PhotoVisibility
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(
        id: String? = nil,
        userId: String,
        url: String,
        caption: String? = nil,
        visibility: PhotoVisibility = .private
    ) {
        self.id = id ?? UUID().uuidString
        self.$user.id = userId
        self.url = url
        self.caption = caption
        self.visibility = visibility
    }
}

enum PhotoVisibility: String, Codable {
    case `private`
    case unlisted
    case `public`
}

// MARK: - Module Model
final class Module: Model, Content {
    static let schema = "modules"
    
    @ID(custom: "id", generatedBy: .user)
    var id: String?
    
    @Field(key: "title")
    var title: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @Field(key: "sort_order")
    var sortOrder: Int
    
    @Field(key: "is_active")
    var isActive: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Children(for: \.$module)
    var lessons: [Lesson]
    
    init() { }
    
    init(
        id: String? = nil,
        title: String,
        description: String? = nil,
        sortOrder: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id ?? UUID().uuidString
        self.title = title
        self.description = description
        self.sortOrder = sortOrder
        self.isActive = isActive
    }
}

// MARK: - Lesson Model
final class Lesson: Model, Content {
    static let schema = "lessons"
    
    @ID(custom: "id", generatedBy: .user)
    var id: String?
    
    @Parent(key: "module_id")
    var module: Module
    
    @Field(key: "title")
    var title: String
    
    @OptionalField(key: "content_url")
    var contentUrl: String?
    
    @Field(key: "sort_order")
    var sortOrder: Int
    
    @Field(key: "is_active")
    var isActive: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(
        id: String? = nil,
        moduleId: String,
        title: String,
        contentUrl: String? = nil,
        sortOrder: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id ?? UUID().uuidString
        self.$module.id = moduleId
        self.title = title
        self.contentUrl = contentUrl
        self.sortOrder = sortOrder
        self.isActive = isActive
    }
}

// MARK: - UserLessonProgress Model
final class UserLessonProgress: Model, Content {
    static let schema = "user_lesson_progress"
    
    @ID(custom: "id", generatedBy: .user)
    var id: String?
    
    @Parent(key: "user_id")
    var user: User
    
    @Parent(key: "lesson_id")
    var lesson: Lesson
    
    @Enum(key: "status")
    var status: ProgressStatus
    
    @OptionalField(key: "started_at")
    var startedAt: Date?
    
    @OptionalField(key: "completed_at")
    var completedAt: Date?
    
    @OptionalField(key: "score")
    var score: Double?
    
    init() { }
    
    init(userId: String, lessonId: String, status: ProgressStatus = .notStarted) {
        self.id = "\(userId)_\(lessonId)"
        self.$user.id = userId
        self.$lesson.id = lessonId
        self.status = status
    }
}

enum ProgressStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
}

// MARK: - Note Model
final class Note: Model, Content {
    static let schema = "notes"
    
    @ID(custom: "id", generatedBy: .user)
    var id: String?
    
    @Parent(key: "user_id")
    var user: User
    
    @OptionalParent(key: "module_id")
    var module: Module?
    
    @OptionalParent(key: "lesson_id")
    var lesson: Lesson?
    
    @OptionalParent(key: "photo_id")
    var photo: Photo?
    
    @OptionalField(key: "title")
    var title: String?
    
    @Field(key: "body")
    var body: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(
        id: String? = nil,
        userId: String,
        body: String,
        title: String? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.$user.id = userId
        self.body = body
        self.title = title
    }
}
