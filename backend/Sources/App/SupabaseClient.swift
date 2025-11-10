import Vapor

struct SupabaseClient {
    let baseURL: String
    let apiKey: String
    let client: Client
    
    init(baseURL: String, apiKey: String, client: Client) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.client = client
    }
    
    // MARK: - Generic Query
    // Performs a GET request to fetch rows from a Supabase table.
    func query<T: Content>(
        table: String,
        select: String = "*",
        filters: [String: String] = [:],
        order: String? = nil
    ) async throws -> [T] {
        var uri = URI(string: "\(baseURL)/rest/v1/\(table)?select=\(select)")
        
        // Agregar filtros
        var queryString = "select=\(select)"
        for (key, value) in filters {
            queryString += "&\(key)=\(value)"
        }
        if let order = order {
            queryString += "&order=\(order)"
        }
        
        uri = URI(string: "\(baseURL)/rest/v1/\(table)?\(queryString)")
        
        let response = try await client.get(uri) { req in
            req.headers.add(name: "apikey", value: apiKey)
            req.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
            req.headers.add(name: "Content-Type", value: "application/json")
            req.headers.add(name: "Prefer", value: "return=representation")
        }
        
        guard response.status == .ok else {
            let bodyString = response.body.flatMap { String(buffer: $0) } ?? "No response body"
            throw Abort(.internalServerError, reason: "Supabase API error: \(response.status) - \(bodyString)")
        }
        
        return try response.content.decode([T].self)
    }
    
    // MARK: - Insert
    // Sends a POST request to insert a new row into a Supabase table.
    func insert<T: Content, R: Content>(table: String, data: T) async throws -> R {
        let uri = URI(string: "\(baseURL)/rest/v1/\(table)")
        
        let response = try await client.post(uri) { req in
            req.headers.add(name: "apikey", value: apiKey)
            req.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
            req.headers.add(name: "Prefer", value: "return=representation")
            try req.content.encode(data)
        }
        
        guard response.status == .created || response.status == .ok else {
            throw Abort(.internalServerError, reason: "Supabase API error: \(response.status)")
        }
        
        let results = try response.content.decode([R].self)
        guard let result = results.first else {
            throw Abort(.internalServerError, reason: "No data returned from insert")
        }
        
        return result
    }
    
    // MARK: - Update
    // Sends a PATCH request to update a row in a Supabase table by ID.
    func update<T: Content, R: Content>(table: String, id: String, data: T) async throws -> R {
        let uri = URI(string: "\(baseURL)/rest/v1/\(table)?id=eq.\(id)")
        
        let response = try await client.patch(uri) { req in
            req.headers.add(name: "apikey", value: apiKey)
            req.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
            req.headers.add(name: "Prefer", value: "return=representation")
            try req.content.encode(data)
        }
        
        guard response.status == .ok else {
            throw Abort(.internalServerError, reason: "Supabase API error: \(response.status)")
        }
        
        let results = try response.content.decode([R].self)
        guard let result = results.first else {
            throw Abort(.notFound)
        }
        
        return result
    }
    
    // MARK: - Delete
    // Sends a DELETE request to remove a row from a Supabase table by ID.
    func delete(table: String, id: String) async throws {
        let uri = URI(string: "\(baseURL)/rest/v1/\(table)?id=eq.\(id)")
        
        let response = try await client.delete(uri) { req in
            req.headers.add(name: "apikey", value: apiKey)
            req.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        }
        
        guard response.status == .noContent || response.status == .ok else {
            throw Abort(.internalServerError, reason: "Supabase API error: \(response.status)")
        }
    }
}

// MARK: - Application Extension
extension Application {
    struct SupabaseClientKey: StorageKey {
        typealias Value = SupabaseClient
    }
    
    var supabase: SupabaseClient {
        get {
            guard let client = storage[SupabaseClientKey.self] else {
                fatalError("SupabaseClient not configured. Call app.supabase = SupabaseClient(...) first.")
            }
            return client
        }
        set {
            storage[SupabaseClientKey.self] = newValue
        }
    }
}

extension Request {
    var supabase: SupabaseClient {
        application.supabase
    }
}
