import Foundation

// MARK: - API Service para Cafecitos App
class CafecitosAPIService {
    static let shared = CafecitosAPIService()
    
    // Cambia esta URL cuando deploys tu API
    private let baseURL = "http://localhost:8080/api"
    
    private init() {}
    
    // MARK: - Modules
    
    /// Obtener todos los módulos
    func fetchModules() async throws -> [Module] {
        let url = URL(string: "\(baseURL)/modules")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Module].self, from: data)
    }
    
    /// Obtener un módulo específico
    func fetchModule(id: String) async throws -> Module {
        let url = URL(string: "\(baseURL)/modules/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Module.self, from: data)
    }
    
    /// Obtener lecciones de un módulo
    func fetchLessons(forModuleId moduleId: String) async throws -> [Lesson] {
        let url = URL(string: "\(baseURL)/modules/\(moduleId)/lessons")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Lesson].self, from: data)
    }
    
    // MARK: - Lessons
    
    /// Obtener todas las lecciones
    func fetchAllLessons() async throws -> [Lesson] {
        let url = URL(string: "\(baseURL)/lessons")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Lesson].self, from: data)
    }
    
    /// Obtener una lección específica
    func fetchLesson(id: String) async throws -> Lesson {
        let url = URL(string: "\(baseURL)/lessons/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Lesson.self, from: data)
    }
    
    // MARK: - Progress
    
    /// Actualizar progreso del usuario
    func updateProgress(userId: String, lessonId: String, status: ProgressStatus, score: Double? = nil) async throws -> UserProgress {
        let url = URL(string: "\(baseURL)/progress")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let progressData: [String: Any] = [
            "user": ["id": userId],
            "lesson": ["id": lessonId],
            "status": status.rawValue,
            "score": score as Any
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: progressData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(UserProgress.self, from: data)
    }
    
    /// Obtener progreso del usuario
    func fetchUserProgress(userId: String) async throws -> [UserProgress] {
        let url = URL(string: "\(baseURL)/users/\(userId)/progress")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([UserProgress].self, from: data)
    }
    
    // MARK: - Users
    
    /// Crear o actualizar usuario
    func createUser(name: String, email: String, description: String? = nil) async throws -> User {
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "description": description as Any
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(User.self, from: data)
    }
}

// MARK: - Models para iOS

struct Module: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let sortOrder: Int
    let isActive: Bool
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct Lesson: Codable, Identifiable {
    let id: String
    let moduleId: String?
    let title: String
    let contentUrl: String?
    let sortOrder: Int
    let isActive: Bool
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case moduleId = "module_id"
        case contentUrl = "content_url"
        case sortOrder = "sort_order"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let description: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, description
        case createdAt = "created_at"
    }
}

struct UserProgress: Codable {
    let userId: String
    let lessonId: String
    let status: ProgressStatus
    let startedAt: Date?
    let completedAt: Date?
    let score: Double?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case lessonId = "lesson_id"
        case status
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case score
    }
}

enum ProgressStatus: String, Codable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
}