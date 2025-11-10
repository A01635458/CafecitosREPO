import SwiftUI
import Combine

// MARK: - API Service
class CafecitosAPIService: ObservableObject {
    static let shared = CafecitosAPIService()
    private let baseURL = "http://localhost:8080"
    
    @Published var modules: [ModuleDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - GET Modules
    func fetchModules() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard let url = URL(string: "\(baseURL)/api/modules") else {
            await MainActor.run {
                errorMessage = "URL inválida"
                isLoading = false
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let fetchedModules = try decoder.decode([ModuleDTO].self, from: data)
            
            await MainActor.run {
                modules = fetchedModules
                isLoading = false
            }
            print("✅ GET exitoso: \(fetchedModules.count) módulos obtenidos")
        } catch {
            await MainActor.run {
                errorMessage = "Error al obtener módulos: \(error.localizedDescription)"
                isLoading = false
            }
            print("❌ Error GET: \(error)")
        }
    }
    
    // MARK: - POST Module
    func createModule(title: String, description: String, sortOrder: Int) async -> ModuleDTO? {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard let url = URL(string: "\(baseURL)/api/modules") else {
            await MainActor.run {
                errorMessage = "URL inválida"
                isLoading = false
            }
            return nil
        }
        
        let newModule = CreateModuleDTO(
            title: title,
            description: description,
            sort_order: sortOrder,
            is_active: true
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(newModule)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                await MainActor.run {
                    errorMessage = "Error del servidor"
                    isLoading = false
                }
                return nil
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let createdModule = try decoder.decode(ModuleDTO.self, from: data)
            print("✅ POST exitoso: Módulo '\(createdModule.title)' creado")
            
            // Recargar lista después de crear
            await fetchModules()
            
            return createdModule
        } catch {
            await MainActor.run {
                errorMessage = "Error al crear módulo: \(error.localizedDescription)"
                isLoading = false
            }
            print("❌ Error POST: \(error)")
            return nil
        }
    }
}

// MARK: - DTOs
struct ModuleDTO: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let sort_order: Int
    let is_active: Bool
    let created_at: Date?
}

struct CreateModuleDTO: Codable {
    let title: String
    let description: String?
    let sort_order: Int?
    let is_active: Bool?
}

// MARK: - Learn View con API Integration
struct LearnView: View {
    @StateObject private var apiService = CafecitosAPIService.shared
    @State private var showCreateSheet = false
    @State private var newModuleTitle = ""
    @State private var newModuleDescription = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - Encabezado
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temario de lecciones")
                            .font(.system(size: 30, weight: .bold))
                        Text("Desde el cultivo hasta la taza")
                            .foregroundStyle(.secondary)
                        
                        // Botones de prueba API
                        HStack(spacing: 12) {
                            Button {
                                Task {
                                    await apiService.fetchModules()
                                }
                            } label: {
                                Label("GET Módulos", systemImage: "arrow.down.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            
                            Button {
                                showCreateSheet = true
                            } label: {
                                Label("POST Módulo", systemImage: "plus.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 8)
                        
                        // Estado de carga
                        if apiService.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Cargando...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        
                        // Error message
                        if let error = apiService.errorMessage {
                            Text("⚠️ \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                        
                        // Contador de módulos
                        if !apiService.modules.isEmpty {
                            Text("📚 \(apiService.modules.count) módulos disponibles")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)

                    // MARK: - Módulos desde API
                    if apiService.modules.isEmpty && !apiService.isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("No hay módulos disponibles")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Presiona 'GET Módulos' para cargar o 'POST Módulo' para crear uno nuevo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(apiService.modules) { module in
                            APIModuleCard(module: module)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
                // Cargar módulos al iniciar
                await apiService.fetchModules()
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateModuleSheet(
                    isPresented: $showCreateSheet,
                    title: $newModuleTitle,
                    description: $newModuleDescription,
                    onSave: {
                        Task {
                            let result = await apiService.createModule(
                                title: newModuleTitle,
                                description: newModuleDescription,
                                sortOrder: apiService.modules.count + 1
                            )
                            if result != nil {
                                showSuccessAlert = true
                                newModuleTitle = ""
                                newModuleDescription = ""
                            }
                        }
                    }
                )
            }
            .alert("✅ Módulo Creado", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("El módulo se creó exitosamente")
            }
        }
    }
}

// MARK: - API Module Card
struct APIModuleCard: View {
    let module: ModuleDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(.system(size: 18, weight: .bold))
                    
                    if let description = module.description {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(module.is_active ? .green : .gray)
                        
                        Text("Orden: \(module.sort_order)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let date = module.created_at {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Image(systemName: "server.rack")
                    .font(.system(size: 30))
                    .foregroundColor(.blue.opacity(0.3))
            }
            
            // Progress bar decorativo
            ProgressView(value: Double(module.sort_order) * 0.25, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding(16)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Create Module Sheet
struct CreateModuleSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información del Módulo") {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nuevo Módulo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        onSave()
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LearnView()
}
