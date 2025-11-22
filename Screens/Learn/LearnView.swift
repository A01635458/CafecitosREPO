import SwiftUI

//Muestra el contenido de la lección usando el campo content_url.
struct LessonDetailView: View {
    let lesson: LessonDTO
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                //Título de la Lección
                Text(lesson.title)
                    .font(.largeTitle.bold())
                    .padding(.bottom, 10)
                
                //Contenido de la Lección
                if let content = lesson.content_url {
                    Text(content)
                        .font(.body)
                        .lineSpacing(4)
                } else {
                    Text("Esta lección no tiene contenido disponible.")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//Componente para mostrar una lección
struct LessonRow: View {
    let lesson: LessonDTO
    
    var body: some View {
        HStack {
            //Icono fijo, sin lógica de is_active
            Image(systemName: "book.fill")
                .foregroundColor(.blue)
            
            Text(lesson.title)
                .font(.system(size: 16))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

//Componente que combina la Tarjeta del Módulo y sus Lecciones
struct ModuleWithLessonsView: View {
    let module: ModuleDTO
    @ObservedObject var apiService: CafecitosAPIService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            APIModuleCard(module: module)
            
            let associatedLessons = apiService.lessons(for: module.id)
            
            if !associatedLessons.isEmpty {
                
                DisclosureGroup(
                    content: {
                        HStack {
                            Text("Lecciones Disponibles (\(associatedLessons.count))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                ) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        ForEach(associatedLessons) { lesson in
                            
                            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                LessonRow(lesson: lesson)
                            }
                            
                            .padding(.horizontal, 20)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    .padding(.top, 4)
                }
                
                .accentColor(.blue)
                .padding(.horizontal, 8)
            }
        }
    }
}

struct LearnView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var apiService = CafecitosAPIService.shared
    @State private var showCreateSheet = false
    @State private var newModuleTitle = ""
    @State private var newModuleDescription = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temario de lecciones")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color.primary)
                        Text("Desde el cultivo hasta la taza")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        //Botones de prueba API
                        HStack(spacing: 12) {
                            Button {
                                Task {
                                    await apiService.fetchModules()
                                }
                            } label: {
                                Label("Obtener Módulos/Lecciones", systemImage: "arrow.down.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                            }
                            
                            Button {
                                showCreateSheet = true
                            } label: {
                                Label("Publicar Módulo", systemImage: "plus.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.green)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.top, 8)
                        
                        //Estado de carga y error
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
                        
                        if let error = apiService.errorMessage {
                            Text("⚠️ \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                        
                        // Contador de módulos y lecciones
                        if !apiService.modules.isEmpty {
                            HStack(spacing: 8) {
                                Text("📚 \(apiService.modules.count) módulos")
                                Text("•")
                                Text("📝 \(apiService.lessons.count) lecciones")
                            }
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)

                    if apiService.modules.isEmpty && !apiService.isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.3))
                                
                            Text("No hay módulos disponibles")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                
                            Text("Presiona 'Obtener Módulos/Lecciones' para cargar o 'Publicar Módulo' para crear uno nuevo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ForEach(apiService.modules) { module in
                            ModuleWithLessonsView(module: module, apiService: apiService)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .task {
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
        .padding(.top, 10)
    }
}

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
