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
    // Debug: Imprimir las variables de entorno para verificar
    app.logger.info("DATABASE_HOST: \(Environment.get("DATABASE_HOST") ?? "NOT SET")")
    app.logger.info("DATABASE_USERNAME: \(Environment.get("DATABASE_USERNAME") ?? "NOT SET")")
    app.logger.info("DATABASE_NAME: \(Environment.get("DATABASE_NAME") ?? "NOT SET")")
    
    guard let dbHost = Environment.get("DATABASE_HOST"),
          let dbPassword = Environment.get("DATABASE_PASSWORD") else {
        app.logger.critical("⚠️ DATABASE_HOST o DATABASE_PASSWORD no están configurados")
        throw Abort(.internalServerError, reason: "Database configuration missing")
    }
    
    let configuration = SQLPostgresConfiguration(
        hostname: dbHost,
        port: Environment.get("DATABASE_PORT").flatMap(Int.init) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: dbPassword,
        database: Environment.get("DATABASE_NAME") ?? "postgres",
        tls: .disable
    )
    app.databases.use(.postgres(configuration: configuration), as: .psql)

    // MARK: - Routes
    try routes(app)
}
