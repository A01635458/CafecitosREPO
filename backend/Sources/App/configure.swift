import Vapor
import Fluent
import FluentPostgresDriver

func configure(_ app: Application) async throws {
    // MARK: - CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    // MARK: - Database (Supabase)
    let configuration = SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "db.xrvsidhefvodmpwnovms.supabase.co",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "postgres",
        tls: .disable // puedes cambiar a .prefer si Supabase lo permite
    )
    app.databases.use(.postgres(configuration: configuration), as: .psql)

    // MARK: - Routes
    try routes(app)
}
