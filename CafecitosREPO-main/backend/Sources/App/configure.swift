import Vapor

func configure(_ app: Application) async throws {
    // MARK: - CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS, .PATCH],
        allowedHeaders: [
            .accept, 
            .authorization, 
            .contentType, 
            .origin, 
            .xRequestedWith,
            HTTPHeaders.Name("x-client-info"),
            HTTPHeaders.Name("apikey")
        ]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    // MARK: - Supabase REST API Client
    guard let supabaseURL = Environment.get("SUPABASE_URL"),
          let supabaseKey = Environment.get("SUPABASE_ANON_KEY") else {
        app.logger.critical("⚠️ SUPABASE_URL o SUPABASE_ANON_KEY no están configurados")
        throw Abort(.internalServerError, reason: "Supabase configuration missing")
    }
    
    app.logger.info("🚀 Configurando Supabase REST API: \(supabaseURL)")
    app.supabase = SupabaseClient(
        baseURL: supabaseURL,
        apiKey: supabaseKey,
        client: app.client
    )

    // MARK: - Routes
    try routes(app)
}

