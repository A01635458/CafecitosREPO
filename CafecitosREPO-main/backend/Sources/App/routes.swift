import Vapor

struct APIInfo: Content {
    let name: String
    let version: String
    let mode: String
    let endpoints: [String]
}

func routes(_ app: Application) throws {
    // Health Check
    app.get("health") { req async -> [String: String] in
        ["status": "ok", "message": "Cafecitos API running with Supabase REST"]
    }

    // Root Info
    app.get { req async throws -> APIInfo in
        APIInfo(
            name: "Cafecitos Learning API",
            version: "1.0.0",
            mode: "Supabase REST API",
            endpoints: [
                "GET /health",
                "GET /api/modules",
                "GET /api/modules/:id",
                "GET /api/modules/:id/lessons",
                "GET /api/lessons",
                "GET /api/lessons/:id",
                "GET /api/users",
                "GET /api/users/:id"
            ]
        )
    }

    // REST Controllers
    try app.register(collection: ModuleRestController())
    try app.register(collection: LessonRestController())
    try app.register(collection: UserRestController())
}
