import Vapor
import Fluent

// MARK: - User Controller
struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.get(use: index)
        users.post(use: create)
        users.group(":userId") { user in
            user.get(use: show)
            user.put(use: update)
            user.delete(use: delete)
            user.get("photos", use: getUserPhotos)
            user.get("notes", use: getUserNotes)
            user.get("progress", use: getUserProgress)
        }
    }
    
    func index(req: Request) async throws -> [User] {
        try await User.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> User {
        let user = try req.content.decode(User.self)
        try await user.save(on: req.db)
        return user
    }
    
    func show(req: Request) async throws -> User {
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return user
    }
    
    func update(req: Request) async throws -> User {
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updateData = try req.content.decode(User.self)
        user.name = updateData.name
        user.email = updateData.email
        user.description = updateData.description
        try await user.save(on: req.db)
        return user
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
    
    func getUserPhotos(req: Request) async throws -> [Photo] {
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$photos.get(on: req.db)
    }
    
    func getUserNotes(req: Request) async throws -> [Note] {
        guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await user.$notes.get(on: req.db)
    }
    
    func getUserProgress(req: Request) async throws -> [UserLessonProgress] {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest)
        }
        return try await UserLessonProgress.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()
    }
}

// MARK: - Photo Controller
struct PhotoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let photos = routes.grouped("api", "photos")
        photos.get(use: index)
        photos.post(use: create)
        photos.group(":photoId") { photo in
            photo.get(use: show)
            photo.put(use: update)
            photo.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [Photo] {
        try await Photo.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Photo {
        let photo = try req.content.decode(Photo.self)
        try await photo.save(on: req.db)
        return photo
    }
    
    func show(req: Request) async throws -> Photo {
        guard let photo = try await Photo.find(req.parameters.get("photoId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return photo
    }
    
    func update(req: Request) async throws -> Photo {
        guard let photo = try await Photo.find(req.parameters.get("photoId"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updateData = try req.content.decode(Photo.self)
        photo.url = updateData.url
        photo.caption = updateData.caption
        photo.visibility = updateData.visibility
        try await photo.save(on: req.db)
        return photo
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let photo = try await Photo.find(req.parameters.get("photoId"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await photo.delete(on: req.db)
        return .noContent
    }
}

// MARK: - Module Controller
struct ModuleController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let modules = routes.grouped("api", "modules")
        modules.get(use: index)
        modules.post(use: create)
        modules.group(":moduleId") { module in
            module.get(use: show)
            module.put(use: update)
            module.delete(use: delete)
            module.get("lessons", use: getLessons)
        }
    }
    
    func index(req: Request) async throws -> [Module] {
        try await Module.query(on: req.db)
            .sort(\.$sortOrder)
            .all()
    }
    
    func create(req: Request) async throws -> Module {
        let module = try req.content.decode(Module.self)
        try await module.save(on: req.db)
        return module
    }
    
    func show(req: Request) async throws -> Module {
        guard let module = try await Module.find(req.parameters.get("moduleId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return module
    }
    
    func update(req: Request) async throws -> Module {
        guard let module = try await Module.find(req.parameters.get("moduleId"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updateData = try req.content.decode(Module.self)
        module.title = updateData.title
        module.description = updateData.description
        module.sortOrder = updateData.sortOrder
        module.isActive = updateData.isActive
        try await module.save(on: req.db)
        return module
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let module = try await Module.find(req.parameters.get("moduleId"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await module.delete(on: req.db)
        return .noContent
    }
    
    func getLessons(req: Request) async throws -> [Lesson] {
        guard let module = try await Module.find(req.parameters.get("moduleId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await module.$lessons.query(on: req.db)
            .sort(\.$sortOrder)
            .all()
    }
}

// MARK: - Lesson Controller
struct LessonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lessons = routes.grouped("api", "lessons")
        lessons.get(use: index)
        lessons.post(use: create)
        lessons.group(":lessonId") { lesson in
            lesson.get(use: show)
            lesson.put(use: update)
            lesson.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [Lesson] {
        try await Lesson.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Lesson {
        let lesson = try req.content.decode(Lesson.self)
        try await lesson.save(on: req.db)
        return lesson
    }
    
    func show(req: Request) async throws -> Lesson {
        guard let lesson = try await Lesson.find(req.parameters.get("lessonId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return lesson
    }
    
    func update(req: Request) async throws -> Lesson {
        guard let lesson = try await Lesson.find(req.parameters.get("lessonId"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updateData = try req.content.decode(Lesson.self)
        lesson.title = updateData.title
        lesson.contentUrl = updateData.contentUrl
        lesson.sortOrder = updateData.sortOrder
        lesson.isActive = updateData.isActive
        try await lesson.save(on: req.db)
        return lesson
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let lesson = try await Lesson.find(req.parameters.get("lessonId"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await lesson.delete(on: req.db)
        return .noContent
    }
}

// MARK: - Note Controller
struct NoteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let notes = routes.grouped("api", "notes")
        notes.get(use: index)
        notes.post(use: create)
        notes.group(":noteId") { note in
            note.get(use: show)
            note.put(use: update)
            note.delete(use: delete)
        }
    }
    
    func index(req: Request) async throws -> [Note] {
        try await Note.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Note {
        let note = try req.content.decode(Note.self)
        try await note.save(on: req.db)
        return note
    }
    
    func show(req: Request) async throws -> Note {
        guard let note = try await Note.find(req.parameters.get("noteId"), on: req.db) else {
            throw Abort(.notFound)
        }
        return note
    }
    
    func update(req: Request) async throws -> Note {
        guard let note = try await Note.find(req.parameters.get("noteId"), on: req.db) else {
            throw Abort(.notFound)
        }
        let updateData = try req.content.decode(Note.self)
        note.title = updateData.title
        note.body = updateData.body
        try await note.save(on: req.db)
        return note
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let note = try await Note.find(req.parameters.get("noteId"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await note.delete(on: req.db)
        return .noContent
    }
}

// MARK: - Progress Controller
struct ProgressController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let progress = routes.grouped("api", "progress")
        progress.post(use: updateProgress)
        progress.get("user", ":userId", "lesson", ":lessonId", use: getProgress)
    }
    
    func updateProgress(req: Request) async throws -> UserLessonProgress {
        let progressData = try req.content.decode(UserLessonProgress.self)
        
        // Buscar si ya existe el progreso
        if let existing = try await UserLessonProgress.query(on: req.db)
            .filter(\.$user.$id == progressData.$user.id)
            .filter(\.$lesson.$id == progressData.$lesson.id)
            .first() {
            
            existing.status = progressData.status
            existing.score = progressData.score
            
            if progressData.status == .completed && existing.completedAt == nil {
                existing.completedAt = Date()
            }
            if progressData.status == .inProgress && existing.startedAt == nil {
                existing.startedAt = Date()
            }
            
            try await existing.save(on: req.db)
            return existing
        } else {
            try await progressData.save(on: req.db)
            return progressData
        }
    }
    
    func getProgress(req: Request) async throws -> UserLessonProgress {
        guard let userId = req.parameters.get("userId"),
              let lessonId = req.parameters.get("lessonId") else {
            throw Abort(.badRequest)
        }
        
        guard let progress = try await UserLessonProgress.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$lesson.$id == lessonId)
            .first() else {
            throw Abort(.notFound)
        }
        
        return progress
    }
}