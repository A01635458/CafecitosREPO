# Integración iOS - Cafecitos API

Este documento proporciona una guía completa para integrar la API de Cafecitos en tu aplicación iOS/SwiftUI.

## Tabla de Contenidos

- [Configuración Inicial](#configuración-inicial)
- [Modelos de Datos](#modelos-de-datos)
- [Servicio de API](#servicio-de-api)
- [ViewModels](#viewmodels)
- [Vistas SwiftUI](#vistas-swiftui)
- [Manejo de Errores](#manejo-de-errores)
- [Ejemplos Completos](#ejemplos-completos)

---

## Configuración Inicial

### 1. Configurar el API Client

Crea un archivo `APIConfig.swift`:

```swift
import Foundation

struct APIConfig {
    static let baseURL = "http://localhost:8080"
    
    // Para producción, usa tu URL de servidor
    // static let baseURL = "https://tu-servidor.com"
    
    static let timeout: TimeInterval = 30
}
```

### 2. Manejo de Errores

Crea `APIError.swift`:

```swift
import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int, message: String)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .invalidResponse:
            return "Respuesta del servidor inválida"
        case .decodingError(let error):
            return "Error al procesar datos: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Error del servidor (\(statusCode)): \(message)"
        case .noData:
            return "No se recibieron datos del servidor"
        }
    }
}
```

---

## Modelos de Datos

Crea `Models.swift` con todos los modelos que coincidan con la API:

```swift
import Foundation

// MARK: - Module
struct Module: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: String?
    let order: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageUrl = "image_url"
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Lesson
struct Lesson: Codable, Identifiable {
    let id: Int
    let moduleId: Int
    let title: String
    let content: String
    let videoUrl: String?
    let duration: Int?
    let order: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case moduleId = "module_id"
        case title
        case content
        case videoUrl = "video_url"
        case duration
        case order
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User
struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let fullName: String
    let profileImageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case fullName = "full_name"
        case profileImageUrl = "profile_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Photo
struct Photo: Codable, Identifiable {
    let id: Int
    let userId: Int
    let imageUrl: String
    let caption: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case imageUrl = "image_url"
        case caption
        case createdAt = "created_at"
    }
}

// MARK: - Note
struct Note: Codable, Identifiable {
    let id: Int
    let userId: Int
    let lessonId: Int
    let content: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lessonId = "lesson_id"
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - UserLessonProgress
struct UserLessonProgress: Codable, Identifiable {
    let id: Int
    let userId: Int
    let lessonId: Int
    let completed: Bool
    let completedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lessonId = "lesson_id"
        case completed
        case completedAt = "completed_at"
    }
}
```

---

## Servicio de API

Crea `APIService.swift` con todos los endpoints:

```swift
import Foundation

class APIService {
    static let shared = APIService()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private init() {}
    
    // MARK: - Generic Request
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = APIConfig.timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Health Check
    func checkHealth() async throws -> HealthResponse {
        return try await request(endpoint: "/health")
    }
    
    // MARK: - Modules
    func getModules() async throws -> [Module] {
        return try await request(endpoint: "/api/modules")
    }
    
    func getModule(id: Int) async throws -> Module {
        return try await request(endpoint: "/api/modules/\(id)")
    }
    
    // MARK: - Lessons
    func getLessons() async throws -> [Lesson] {
        return try await request(endpoint: "/api/lessons")
    }
    
    func getLesson(id: Int) async throws -> Lesson {
        return try await request(endpoint: "/api/lessons/\(id)")
    }
    
    func getLessonsByModule(moduleId: Int) async throws -> [Lesson] {
        return try await request(endpoint: "/api/modules/\(moduleId)/lessons")
    }
    
    // MARK: - Users
    func getUsers() async throws -> [User] {
        return try await request(endpoint: "/api/users")
    }
    
    func getUser(id: Int) async throws -> User {
        return try await request(endpoint: "/api/users/\(id)")
    }
    
    // MARK: - Photos
    func getPhotos() async throws -> [Photo] {
        return try await request(endpoint: "/api/photos")
    }
    
    func getPhotosByUser(userId: Int) async throws -> [Photo] {
        return try await request(endpoint: "/api/users/\(userId)/photos")
    }
    
    // MARK: - Notes
    func getNotesByLesson(lessonId: Int, userId: Int) async throws -> [Note] {
        return try await request(endpoint: "/api/lessons/\(lessonId)/notes?user_id=\(userId)")
    }
    
    // MARK: - Progress
    func getProgress(userId: Int) async throws -> [UserLessonProgress] {
        return try await request(endpoint: "/api/users/\(userId)/progress")
    }
}

// MARK: - Response Models
struct HealthResponse: Codable {
    let status: String
    let message: String
}
```

---

## ViewModels

### ModulesViewModel

Crea `ModulesViewModel.swift`:

```swift
import Foundation

@MainActor
class ModulesViewModel: ObservableObject {
    @Published var modules: [Module] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadModules() async {
        isLoading = true
        errorMessage = nil
        
        do {
            modules = try await apiService.getModules()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading modules: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshModules() async {
        await loadModules()
    }
}
```

### LessonsViewModel

Crea `LessonsViewModel.swift`:

```swift
import Foundation

@MainActor
class LessonsViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadLessons(for moduleId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            lessons = try await apiService.getLessonsByModule(moduleId: moduleId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading lessons: \(error)")
        }
        
        isLoading = false
    }
    
    func loadAllLessons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            lessons = try await apiService.getLessons()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading lessons: \(error)")
        }
        
        isLoading = false
    }
}
```

### UserProgressViewModel

Crea `UserProgressViewModel.swift`:

```swift
import Foundation

@MainActor
class UserProgressViewModel: ObservableObject {
    @Published var progress: [UserLessonProgress] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadProgress(for userId: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            progress = try await apiService.getProgress(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading progress: \(error)")
        }
        
        isLoading = false
    }
    
    func isLessonCompleted(_ lessonId: Int) -> Bool {
        progress.first { $0.lessonId == lessonId }?.completed ?? false
    }
    
    func completionPercentage() -> Double {
        guard !progress.isEmpty else { return 0 }
        let completed = progress.filter { $0.completed }.count
        return Double(completed) / Double(progress.count) * 100
    }
}
```

---

## Vistas SwiftUI

### Vista Principal - ModulesListView

```swift
import SwiftUI

struct ModulesListView: View {
    @StateObject private var viewModel = ModulesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Cargando módulos...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Error")
                            .font(.title2)
                            .bold()
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Reintentar") {
                            Task {
                                await viewModel.loadModules()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    List(viewModel.modules) { module in
                        NavigationLink(destination: ModuleDetailView(module: module)) {
                            ModuleRowView(module: module)
                        }
                    }
                    .refreshable {
                        await viewModel.refreshModules()
                    }
                }
            }
            .navigationTitle("Cafecitos")
            .task {
                await viewModel.loadModules()
            }
        }
    }
}

struct ModuleRowView: View {
    let module: Module
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(module.title)
                .font(.headline)
            
            Text(module.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
```

### Vista de Detalle - ModuleDetailView

```swift
import SwiftUI

struct ModuleDetailView: View {
    let module: Module
    @StateObject private var viewModel = LessonsViewModel()
    @StateObject private var progressViewModel = UserProgressViewModel()
    
    // Reemplaza con el ID del usuario actual
    private let currentUserId = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(module.title)
                        .font(.title)
                        .bold()
                    
                    Text(module.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    if !progressViewModel.progress.isEmpty {
                        ProgressBarView(
                            progress: progressViewModel.completionPercentage() / 100,
                            label: "\(Int(progressViewModel.completionPercentage()))% completado"
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Lessons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lecciones")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ForEach(viewModel.lessons) { lesson in
                            NavigationLink(destination: LessonDetailView(
                                lesson: lesson,
                                isCompleted: progressViewModel.isLessonCompleted(lesson.id)
                            )) {
                                LessonRowView(
                                    lesson: lesson,
                                    isCompleted: progressViewModel.isLessonCompleted(lesson.id)
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(module.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadLessons(for: module.id)
            await progressViewModel.loadProgress(for: currentUserId)
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion indicator
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isCompleted ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let duration = lesson.duration {
                    Text("\(duration) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct ProgressBarView: View {
    let progress: Double
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}
```

### Vista de Lección - LessonDetailView

```swift
import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    let isCompleted: Bool
    
    @State private var showingCompletionAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video placeholder (si hay URL)
                if let videoUrl = lesson.videoUrl {
                    VideoPlaceholderView(videoUrl: videoUrl)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(lesson.title)
                            .font(.title)
                            .bold()
                        
                        Spacer()
                        
                        if isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    
                    if let duration = lesson.duration {
                        Label("\(duration) minutos", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Text(lesson.content)
                        .font(.body)
                        .lineSpacing(8)
                }
                .padding()
                
                // Complete button
                if !isCompleted {
                    Button(action: {
                        showingCompletionAlert = true
                    }) {
                        Label("Marcar como completada", systemImage: "checkmark.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("¡Lección Completada!", isPresented: $showingCompletionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Has completado la lección: \(lesson.title)")
        }
    }
}

struct VideoPlaceholderView: View {
    let videoUrl: String
    
    var body: some View {
        VStack {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color.black)
    }
}
```

---

## Manejo de Errores

### Vista de Error Reutilizable

```swift
import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Algo salió mal")
                .font(.title2)
                .bold()
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Reintentar") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### Vista de Carga

```swift
import SwiftUI

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .foregroundColor(.secondary)
        }
    }
}
```

---

## Ejemplos Completos

### App Principal

```swift
import SwiftUI

@main
struct CafecitosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            ModulesListView()
                .tabItem {
                    Label("Módulos", systemImage: "book.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
    }
}
```

### Vista de Perfil con Progreso

```swift
import SwiftUI

struct ProfileView: View {
    @StateObject private var progressViewModel = UserProgressViewModel()
    @State private var user: User?
    
    // Reemplaza con el ID del usuario actual
    private let currentUserId = 1
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User info
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        if let user = user {
                            Text(user.fullName)
                                .font(.title2)
                                .bold()
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Mi Progreso")
                            .font(.title2)
                            .bold()
                        
                        if progressViewModel.isLoading {
                            ProgressView()
                        } else if !progressViewModel.progress.isEmpty {
                            VStack(spacing: 12) {
                                StatCardView(
                                    title: "Lecciones Completadas",
                                    value: "\(progressViewModel.progress.filter { $0.completed }.count)",
                                    total: "\(progressViewModel.progress.count)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                                
                                StatCardView(
                                    title: "Progreso Total",
                                    value: "\(Int(progressViewModel.completionPercentage()))",
                                    total: "100%",
                                    icon: "chart.bar.fill",
                                    color: .blue
                                )
                            }
                        } else {
                            Text("No hay datos de progreso disponibles")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Perfil")
            .task {
                await loadUserData()
                await progressViewModel.loadProgress(for: currentUserId)
            }
        }
    }
    
    private func loadUserData() async {
        do {
            user = try await APIService.shared.getUser(id: currentUserId)
        } catch {
            print("Error loading user: \(error)")
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let total: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title)
                        .bold()
                    
                    Text("/ \(total)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
```

---

## Testing de la Integración

### Test de Conectividad

```swift
import SwiftUI

struct APITestView: View {
    @State private var healthStatus: String = "No probado"
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Prueba de API")
                .font(.title)
                .bold()
            
            Text("Estado: \(healthStatus)")
                .foregroundColor(healthStatus == "OK" ? .green : .secondary)
            
            Button("Probar Conexión") {
                Task {
                    await testConnection()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            }
        }
        .padding()
    }
    
    private func testConnection() async {
        isLoading = true
        
        do {
            let response = try await APIService.shared.checkHealth()
            healthStatus = response.status.uppercased()
        } catch {
            healthStatus = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
```

---

## Consejos de Implementación

### 1. Configuración para Desarrollo

Para conectar con el servidor local desde el simulador de iOS:
- Usa `http://localhost:8080` para simulador
- Usa `http://<tu-ip-local>:8080` para dispositivos físicos

### 2. Manejo de Imágenes

Para cargar imágenes desde URLs:

```swift
import SwiftUI

struct AsyncImageView: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}
```

### 3. Cache de Datos

Para mejorar la experiencia del usuario, implementa cache:

```swift
import Foundation

class CacheManager {
    static let shared = CacheManager()
    private var cache = NSCache<NSString, NSData>()
    
    private init() {
        cache.countLimit = 100
    }
    
    func set(_ data: Data, for key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func get(for key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
}
```

### 4. Configuración de Networking

Añade en tu `Info.plist` para permitir conexiones HTTP en desarrollo:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

---

## Próximos Pasos

1. **Autenticación**: Implementar login/registro de usuarios
2. **Persistencia**: Usar Core Data o SwiftData para datos offline
3. **Notificaciones**: Push notifications para nuevo contenido
4. **Analytics**: Tracking de progreso y uso de la app
5. **Compartir**: Función para compartir fotos y notas

---

## Troubleshooting

### Problema: "Cannot connect to localhost"
**Solución**: Verifica que el servidor esté corriendo en `http://localhost:8080`

### Problema: "SSL Error"
**Solución**: Añade `NSAppTransportSecurity` en Info.plist como se muestra arriba

### Problema: "Decoding Error"
**Solución**: Verifica que los modelos coincidan exactamente con la respuesta de la API

### Problema: "Task was cancelled"
**Solución**: Aumenta el timeout en `APIConfig.timeout`

---

## Recursos Adicionales

- [Documentación de API Backend](./README.md)
- [Supabase Documentation](https://supabase.com/docs)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Async/Await in Swift](https://developer.apple.com/documentation/swift/concurrency)

---

**Última actualización**: Noviembre 2025  
**Versión de API**: 1.0  
**Compatibilidad iOS**: iOS 15.0+
