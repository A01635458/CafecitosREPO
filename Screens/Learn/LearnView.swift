import SwiftUI

extension Binding where Value == String? {
    var bound: Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

extension Binding where Value == ModuleDTO? {
    var isNotNil: Binding<Bool> {
        return Binding<Bool>(
            get: { self.wrappedValue != nil },
            set: { isPresenting in
                if !isPresenting {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

//Estructura de lecciones
struct LessonDetailView: View {
    let lesson: LessonDTO
    @StateObject private var apiService = CafecitosAPIService.shared
    @State private var isActive: Bool
    
    init(lesson: LessonDTO) {
        self.lesson = lesson
        _isActive = State(initialValue: lesson.is_active)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text(lesson.title).font(.largeTitle.bold()).padding(.bottom, 10)
                
                if let urlLink = lesson.url_link, !urlLink.isEmpty {
                    Text("**Enlace de Video:**").font(.headline)
                    if let url = URL(string: urlLink) {
                         Link(urlLink, destination: url)
                            .font(.body).foregroundColor(.blue).underline()
                            .padding(.bottom, 10)
                    } else {
                        Text("Enlace no válido").foregroundColor(.red).padding(.bottom, 10)
                    }
                }

                if let content = lesson.content_url, !content.isEmpty {
                    Text("**Contenido de Texto:**").font(.headline)
                    Text(content).font(.body).lineSpacing(4)
                } else if (lesson.url_link == nil || lesson.url_link!.isEmpty) {
                    Text("Esta lección no tiene contenido disponible.").foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Text("Estado: **\(isActive ? "Activa" : "Inactiva")**").font(.subheadline)
                    Spacer()
                    Toggle("Activa", isOn: $isActive)
                        .labelsHidden()
                        .onChange(of: isActive) { newValue in
                            Task {
                                _ = await apiService.updateLessonStatus(lessonID: lesson.id, isActive: newValue)
                            }
                        }
                }.padding(.top, 20)
                
            }.padding()
        }
        .navigationTitle(lesson.title).navigationBarTitleDisplayMode(.inline)
    }
}
//Estrcutura de manipulacion
struct LessonRow: View {
    let lesson: LessonDTO
    
    var body: some View {
        HStack {
            Image(systemName: lesson.is_active ? "book.fill" : "lock.circle.fill")
                .foregroundColor(lesson.is_active ? .blue : .gray)
            
            Text(lesson.title).font(.system(size: 16))
            
            if lesson.url_link != nil && !lesson.url_link!.isEmpty {
                 Image(systemName: "video.fill").foregroundColor(.red).font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }.padding(.vertical, 8)
    }
}

//La carta creada
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
//Moudlo con lecciones
struct ModuleWithLessonsView: View {
    let module: ModuleDTO
    @ObservedObject var apiService: CafecitosAPIService
    
    @State private var isShowingLessons = true
    @Binding var moduleToEdit: ModuleDTO?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            APIModuleCard(module: module)
                .onTapGesture {
                    moduleToEdit = module
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    
                    Button(role: .destructive) {
                        Task { _ = await apiService.deleteModule(moduleID: module.id) }
                    } label: { Label("Eliminar", systemImage: "trash.fill") }
                    
                    Button {
                        moduleToEdit = module
                    } label: { Label("Editar", systemImage: "pencil.circle.fill") }
                    .tint(.blue)
                }

            let associatedLessons = apiService.lessons(for: module.id)
            
            if !associatedLessons.isEmpty {
                DisclosureGroup(
                    isExpanded: $isShowingLessons,
                    content: {
                        HStack {
                            Text("Lecciones Disponibles (\(associatedLessons.count))").font(.subheadline).fontWeight(.semibold)
                            Spacer()
                        }.padding(.horizontal, 20).padding(.vertical, 8)
                    }
                ) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(associatedLessons) { lesson in
                            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                LessonRow(lesson: lesson)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task { _ = await apiService.deleteLesson(lessonID: lesson.id) }
                                } label: { Label("Eliminar", systemImage: "trash.fill") }
                            }
                            .padding(.horizontal, 20).listRowInsets(EdgeInsets())
                        }
                    }
                    .padding(.top, 4)
                }.accentColor(.blue).padding(.horizontal, 8)
            }
        }
    }
}

//Crear modulo
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
//Para editar el contenido
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
                            // Guardado inmediato del estado is_active
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

//Establece como se vera la vista
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
                        Text("Desde el cultivo hasta la taza").font(.subheadline).foregroundColor(.secondary)
                        
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
                            ModuleWithLessonsView(module: module, apiService: apiService, moduleToEdit: $moduleToEdit)
                        }
                    }
                }.padding(.bottom, 80)
            }
            .background(Color(UIColor.systemBackground)).navigationTitle("").navigationBarHidden(true)
            .task { await apiService.fetchModules() }
            
            //Pasa y usa el estado newModuleIsActive
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
