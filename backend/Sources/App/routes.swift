import Vapor

func routes(_ app: Application) throws {
    // Health Check
    app.get("health") { req async -> [String: String] in
        ["status": "ok", "message": "Cafecitos API running"]
    }

    // Root Info
    app.get { req async throws -> Response in
        let json: [String: Any] = [
            "name": "Cafecitos Learning API",
            "version": "1.0.0",
            "endpoints": [
                "GET /health",
                "GET /api/modules",
                "GET /api/modules/:id",
                "GET /api/modules/:id/lessons",
                "GET /api/lessons",
                "GET /api/lessons/:id",
                "POST /api/progress",
                "GET /api/users/:id/progress"
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: json)
        return Response(status: .ok, body: .init(data: data))
    }

    // Controllers
    try app.register(collection: UserController())
    try app.register(collection: PhotoController())
    try app.register(collection: ModuleController())
    try app.register(collection: LessonController())
    try app.register(collection: NoteController())
    try app.register(collection: ProgressController())
}
