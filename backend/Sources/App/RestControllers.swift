import Vapor

// MARK: - Module Controller (REST API)
struct ModuleRestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let modules = routes.grouped("api", "modules")
        modules.get(use: index)
        modules.get(":moduleId", use: show)
        modules.get(":moduleId", "lessons", use: getLessons)
    }
    
    func index(req: Request) async throws -> [ModuleDTO] {
        req.logger.info("📚 Fetching modules from Supabase REST API")
        return try await req.supabase.query(
            table: "modules",
            order: "sort_order.asc"
        )
    }
    
    func show(req: Request) async throws -> ModuleDTO {
        guard let moduleId = req.parameters.get("moduleId") else {
            throw Abort(.badRequest, reason: "Missing module ID")
        }
        
        req.logger.info("📚 Fetching module \(moduleId) from Supabase")
        let modules: [ModuleDTO] = try await req.supabase.query(
            table: "modules",
            filters: ["id": "eq.\(moduleId)"]
        )
        
        guard let module = modules.first else {
            throw Abort(.notFound, reason: "Module not found")
        }
        
        return module
    }
    
    func getLessons(req: Request) async throws -> [LessonDTO] {
        guard let moduleId = req.parameters.get("moduleId") else {
            throw Abort(.badRequest, reason: "Missing module ID")
        }
        
        req.logger.info("📖 Fetching lessons for module \(moduleId)")
        return try await req.supabase.query(
            table: "lessons",
            filters: ["module_id": "eq.\(moduleId)"],
            order: "sort_order.asc"
        )
    }
}

// MARK: - Lesson Controller (REST API)
struct LessonRestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lessons = routes.grouped("api", "lessons")
        lessons.get(use: index)
        lessons.get(":lessonId", use: show)
    }
    
    func index(req: Request) async throws -> [LessonDTO] {
        req.logger.info("📖 Fetching all lessons from Supabase")
        return try await req.supabase.query(
            table: "lessons",
            order: "sort_order.asc"
        )
    }
    
    func show(req: Request) async throws -> LessonDTO {
        guard let lessonId = req.parameters.get("lessonId") else {
            throw Abort(.badRequest, reason: "Missing lesson ID")
        }
        
        req.logger.info("📖 Fetching lesson \(lessonId)")
        let lessons: [LessonDTO] = try await req.supabase.query(
            table: "lessons",
            filters: ["id": "eq.\(lessonId)"]
        )
        
        guard let lesson = lessons.first else {
            throw Abort(.notFound, reason: "Lesson not found")
        }
        
        return lesson
    }
}

// MARK: - User Controller (REST API)
struct UserRestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.get(use: index)
        users.get(":userId", use: show)
    }
    
    func index(req: Request) async throws -> [UserDTO] {
        req.logger.info("👥 Fetching all users")
        return try await req.supabase.query(table: "users")
    }
    
    func show(req: Request) async throws -> UserDTO {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "Missing user ID")
        }
        
        let users: [UserDTO] = try await req.supabase.query(
            table: "users",
            filters: ["id": "eq.\(userId)"]
        )
        
        guard let user = users.first else {
            throw Abort(.notFound)
        }
        
        return user
    }
}
