import Vapor

// MARK: - Module Controller (REST API)
struct ModuleRestController: RouteCollection {
    // Registers all module-related routes under /api/modules
    func boot(routes: RoutesBuilder) throws {
        let modules = routes.grouped("api", "modules")
        modules.get(use: index)                         // GET /api/modules
        modules.post(use: create)                       // POST /api/modules 
        modules.get(":moduleId", use: show)             // GET /api/modules/:moduleId 
        modules.put(":moduleId", use: update)           // PUT /api/modules/:moduleId 
        modules.delete(":moduleId", use: delete)        // DELETE /api/modules/:moduleId 
        modules.get(":moduleId", "lessons", use: getLessons) // GET /api/modules/:moduleId/lessons 
    }


    // Returns all modules ordered by sort_order
    func index(req: Request) async throws -> [ModuleDTO] {
        req.logger.info("📚 Fetching modules from Supabase REST API")
        return try await req.supabase.query(
            table: "modules",
            order: "sort_order.asc"
        )
    }
    // Returns a single module matching the given :moduleId
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
    
       // Creates a new module record in the "modules" table
    func create(req: Request) async throws -> ModuleDTO {
        let input = try req.content.decode(CreateModuleDTO.self)
        req.logger.info("📚 Creating new module: \(input.title)")
        
        let module: ModuleDTO = try await req.supabase.insert(
            table: "modules",
            data: input
        )
        
        return module
    }
    
        // Updates an existing module by ID 
    func update(req: Request) async throws -> ModuleDTO {
        guard let moduleId = req.parameters.get("moduleId") else {
            throw Abort(.badRequest, reason: "Missing module ID")
        }
        
        let input = try req.content.decode(UpdateModuleDTO.self)
        req.logger.info("📚 Updating module \(moduleId)")
        
        let module: ModuleDTO = try await req.supabase.update(
            table: "modules",
            id: moduleId,
            data: input
        )
        
        return module
    }
        // Deletes a module by ID
    func delete(req: Request) async throws -> HTTPStatus {
        guard let moduleId = req.parameters.get("moduleId") else {
            throw Abort(.badRequest, reason: "Missing module ID")
        }
        
        req.logger.info("📚 Deleting module \(moduleId)")
        try await req.supabase.delete(
            table: "modules",
            id: moduleId
        )
        
        return .noContent
    }
        // Returns all lessons belonging to a specific module
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
    // Registers all lesson-related routes under /api/lessons
    func boot(routes: RoutesBuilder) throws {
        let lessons = routes.grouped("api", "lessons")
        lessons.get(use: index)                         // GET /api/lessons – list all lessons
        lessons.post(use: create)                       // POST /api/lessons – create a new lesson
        lessons.get(":lessonId", use: show)             // GET /api/lessons/:lessonId – get a single lesson
        lessons.put(":lessonId", use: update)           // PUT /api/lessons/:lessonId – update a lesson
        lessons.delete(":lessonId", use: delete)        // DELETE /api/lessons/:lessonId – delete a lesson
    }
        // Returns all lessons ordered by sort_order
    func index(req: Request) async throws -> [LessonDTO] {
        req.logger.info("📖 Fetching all lessons from Supabase")
        return try await req.supabase.query(
            table: "lessons",
            order: "sort_order.asc"
        )
    }
        // Returns a single lesson by ID
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
        // Creates a new lesson record in the "lessons" table
    func create(req: Request) async throws -> LessonDTO {
        let input = try req.content.decode(CreateLessonDTO.self)
        req.logger.info("📖 Creating new lesson: \(input.title)")
        
        let lesson: LessonDTO = try await req.supabase.insert(
            table: "lessons",
            data: input
        )
        
        return lesson
    }
        // Updates an existing lesson by ID
    func update(req: Request) async throws -> LessonDTO {
        guard let lessonId = req.parameters.get("lessonId") else {
            throw Abort(.badRequest, reason: "Missing lesson ID")
        }
        
        let input = try req.content.decode(UpdateLessonDTO.self)
        req.logger.info("📖 Updating lesson \(lessonId)")
        
        let lesson: LessonDTO = try await req.supabase.update(
            table: "lessons",
            id: lessonId,
            data: input
        )
        
        return lesson
    }
        // Deletes a lesson by ID
    func delete(req: Request) async throws -> HTTPStatus {
        guard let lessonId = req.parameters.get("lessonId") else {
            throw Abort(.badRequest, reason: "Missing lesson ID")
        }
        
        req.logger.info("📖 Deleting lesson \(lessonId)")
        try await req.supabase.delete(
            table: "lessons",
            id: lessonId
        )
        
        return .noContent
    }
}

// MARK: - User Controller (REST API)
struct UserRestController: RouteCollection {
    // Registers routes under /api/users
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.get(use: index)                           // GET /api/users – list all users
        users.get(":userId", use: show)                 // GET /api/users/:userId – get a single user
    }
        // Returns all users from the "users" table
    func index(req: Request) async throws -> [UserDTO] {
        req.logger.info("👥 Fetching all users")
        return try await req.supabase.query(table: "users")
    }
        // Returns a single user by ID
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
