import SwiftUI

// MARK: - Vistas Auxiliares de Módulos

struct APIModuleCard: View {
    let module: ModuleDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title).font(.system(size: 18, weight: .bold)).foregroundColor(.primary)
                    
                    if let description = module.description {
                        Text(description).font(.system(size: 14)).foregroundColor(.secondary).lineLimit(2)
                    }
                    
                    HStack(spacing: 8) {
                        Text("Orden: \(module.sort_order)"); Text("•"); Text("Estado: \(module.is_active ? "Activo" : "Inactivo")")
                    }
                    .font(.caption).foregroundColor(.gray).padding(.top, 4)
                    
                    if let url = module.url_link, !url.isEmpty, let validUrl = URL(string: url) {
                        Link("Ver video del módulo", destination: validUrl)
                            .font(.caption).foregroundColor(.blue)
                    }
                }
                Spacer()
                Image(systemName: "server.rack").font(.system(size: 30)).foregroundColor(.blue.opacity(0.3))
            }
            ProgressView(value: Double(module.sort_order), total: Double(10)).progressViewStyle(LinearProgressViewStyle(tint: .blue)).frame(maxWidth: .infinity)
        }
        .padding(16).background(Color(.systemBackground)).cornerRadius(12).shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20).padding(.top, 8)
    }
}

struct CreateModuleSheet: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var description: String
    @Binding var urlLink: String
    @Binding var isActive: Bool
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Módulo") {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical).lineLimit(3...6)
                }
                Section("Contenido Multimedia") {
                    TextField("URL de Video (YouTube)", text: $urlLink)
                }
                Section("Estado") {
                    Toggle("Módulo Activo", isOn: $isActive)
                }
            }
            .navigationTitle("Nuevo Módulo").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { isPresented = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") { onSave(); isPresented = false }.disabled(title.isEmpty)
                }
            }
        }
    }
}

struct EditModuleSheet: View {
    @Binding var isPresented: Bool
    @State var currentModule: ModuleDTO
    let onUpdate: (ModuleDTO) -> Void
    @ObservedObject var apiService = CafecitosAPIService.shared
    
    init(isPresented: Binding<Bool>, module: Binding<ModuleDTO>, onUpdate: @escaping (ModuleDTO) -> Void) {
        self._isPresented = isPresented
        self._currentModule = State(initialValue: module.wrappedValue)
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información del Módulo") {
                    TextField("Título", text: $currentModule.title)
                    TextField("Descripción", text: $currentModule.description.bound, axis: .vertical).lineLimit(3...6)
                    Stepper("Orden: \(currentModule.sort_order)", value: $currentModule.sort_order)
                }
                Section("Estado y Contenido") {
                    Toggle("Módulo Activo", isOn: $currentModule.is_active)
                        .onChange(of: currentModule.is_active) { newValue in
                            Task {
                                _ = await apiService.updateModuleStatus(moduleID: currentModule.id, isActive: newValue)
                            }
                        }
                    TextField("URL de Video (YouTube)", text: $currentModule.url_link.bound)
                }
                Section("Metadatos (Solo Lectura)") {
                    Text("ID: \(currentModule.id.uuidString)").font(.caption)
                    if let date = currentModule.created_at { Text("Creado: \(date, style: .date)") }
                }
            }
            .navigationTitle("Editar Módulo").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { isPresented = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onUpdate(currentModule)
                        isPresented = false
                    }.disabled(currentModule.title.isEmpty)
                }
            }
        }
    }
}

// MARK: - LearnView (Vista Principal / CRUD de Módulos)

struct LearnView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var apiService = CafecitosAPIService.shared
    
    @State private var showCreateSheet = false
    @State private var newModuleTitle = ""
    @State private var newModuleDescription = ""
    @State private var newModuleUrlLink = ""
    @State private var newModuleIsActive = true
    @State private var showSuccessAlert = false
    
    @State private var moduleToEdit: ModuleDTO? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temario de lecciones").font(.largeTitle.bold()).foregroundColor(Color.primary)
                        Text("Gestión de módulos y lecciones").font(.subheadline).foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button { Task { await apiService.fetchModules() } } label: {
                                Label("Obtener Módulos/Lecciones", systemImage: "arrow.down.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(Color.blue).cornerRadius(10).shadow(radius: 3)
                            }
                            Button { showCreateSheet = true } label: {
                                Label("Publicar Módulo", systemImage: "plus.circle.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(Color.green).cornerRadius(10).shadow(radius: 3)
                            }
                        }
                        
                        if apiService.isLoading { HStack { ProgressView().scaleEffect(0.8) } }
                        if let error = apiService.errorMessage { Text("⚠️ \(error)").font(.caption).foregroundColor(.red).padding(.top, 4) }
                        
                        if !apiService.modules.isEmpty {
                            HStack(spacing: 8) { Text("📚 \(apiService.modules.count) módulos"); Text("•"); Text("📝 \(apiService.lessons.count) lecciones") }
                                .font(.caption).foregroundColor(.green).padding(.top, 4)
                        }
                    }.padding(.top, 50).padding(.horizontal, 20)
                    
                    if apiService.modules.isEmpty && !apiService.isLoading {
                        VStack(spacing: 16) {
                            Image(systemName: "tray").font(.system(size: 60)).foregroundColor(.gray.opacity(0.3))
                            Text("No hay módulos disponibles").font(.headline).foregroundColor(.secondary)
                        }.frame(maxWidth: .infinity).padding(.vertical, 60)
                    } else {
                        ForEach(apiService.modules) { module in
                            NavigationLink(destination: ModuleLessonView(module: module, apiService: apiService, moduleToEdit: $moduleToEdit)) {
                                APIModuleCard(module: module)
                            }.buttonStyle(.plain)
                        }
                    }
                }.padding(.bottom, 80)
            }
            .background(Color(UIColor.systemBackground)).navigationTitle("").navigationBarHidden(true)
            .task { await apiService.fetchModules() }
            
            .sheet(isPresented: $showCreateSheet) {
                CreateModuleSheet(
                    isPresented: $showCreateSheet,
                    title: $newModuleTitle,
                    description: $newModuleDescription,
                    urlLink: $newModuleUrlLink,
                    isActive: $newModuleIsActive,
                    onSave: {
                        Task {
                            let result = await apiService.createModule(
                                title: newModuleTitle,
                                description: newModuleDescription,
                                urlLink: newModuleUrlLink,
                                isActive: newModuleIsActive,
                                sortOrder: apiService.modules.count + 1
                            )
                            if result != nil { showSuccessAlert = true }
                            
                            newModuleTitle = ""
                            newModuleDescription = ""
                            newModuleUrlLink = ""
                            newModuleIsActive = true
                        }
                    }
                )
            }
            
            .sheet(item: $moduleToEdit) { module in
                EditModuleSheet(
                    isPresented: $moduleToEdit.isNotNil,
                    module: .constant(module),
                    onUpdate: { updatedModule in
                        Task {
                            _ = await apiService.updateModule(module: updatedModule)
                        }
                    }
                )
            }
            
            .alert("✅ Módulo Creado", isPresented: $showSuccessAlert) { Button("OK", role: .cancel) { } } message: { Text("El módulo se creó exitosamente") }
        }
    }
}
