//
//  ModuleLessonView.swift
//  KaapehApp
//
//  Created by Alumno on 01/12/25.
//

import SwiftUI

// MARK: - Vistas Auxiliares de Lecciones

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
                
                if let content = lesson.content, !content.isEmpty {
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

struct EditLessonSheet: View {
    @Binding var isPresented: Bool
    @State var currentLesson: LessonDTO
    let onUpdate: (LessonDTO) -> Void
    @ObservedObject var apiService = CafecitosAPIService.shared
    
    init(isPresented: Binding<Bool>, lesson: Binding<LessonDTO>, onUpdate: @escaping (LessonDTO) -> Void) {
        self._isPresented = isPresented
        self._currentLesson = State(initialValue: lesson.wrappedValue)
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información de la Lección") {
                    TextField("Título", text: $currentLesson.title)
                    Stepper("Orden: \(currentLesson.sort_order)", value: $currentLesson.sort_order)
                }
                Section("Contenido (Texto y Enlace)") {
                    TextField("Contenido de Texto Largo", text: $currentLesson.content.bound, axis: .vertical).lineLimit(5...10)
                    TextField("URL de Video (Enlace Externo)", text: $currentLesson.url_link.bound)
                }
                Section("Estado") {
                    Toggle("Lección Activa", isOn: $currentLesson.is_active)
                        .onChange(of: currentLesson.is_active) { newValue in
                            Task {
                                _ = await apiService.updateLessonStatus(lessonID: currentLesson.id, isActive: newValue)
                            }
                        }
                }
            }
            .navigationTitle("Editar Lección").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { isPresented = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onUpdate(currentLesson)
                        isPresented = false
                    }.disabled(currentLesson.title.isEmpty)
                }
            }
        }
    }
}


// MARK: - ModuleLessonView (Detalle de Módulo / CRUD de Lecciones)

struct ModuleLessonView: View {
    let module: ModuleDTO
    @ObservedObject var apiService: CafecitosAPIService
    
    @Binding var moduleToEdit: ModuleDTO?
    
    @State private var newLessonError: String? = nil
    @State private var lessonToEdit: LessonDTO? = nil
    @State private var showCreateLessonSheet = false
    
    var filteredLessons: [LessonDTO] {
        apiService.lessons
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
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
                
                Text("Lecciones Disponibles (\(filteredLessons.count))")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                if filteredLessons.isEmpty {
                    Text("No hay lecciones en el temario.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    List {
                        ForEach(filteredLessons) { lesson in
                            
                            NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                LessonRow(lesson: lesson)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                
                                Button(role: .destructive) {
                                    Task { _ = await apiService.deleteLesson(lessonID: lesson.id) }
                                } label: { Label("Eliminar", systemImage: "trash.fill") }
                                
                                Button {
                                    lessonToEdit = lesson
                                } label: { Label("Editar", systemImage: "pencil.circle.fill") }
                                .tint(.blue)
                            }
                        }
                    }
                    .frame(height: min(CGFloat(filteredLessons.count) * 60 + 20, 400))
                    .listStyle(.plain)
                }
                
                Divider().padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Operaciones de Lecciones")
                        .font(.subheadline.bold())
                        .foregroundColor(.accentColor)
                    
                    Button("➕ Crear Nueva Lección") {
                        showCreateLessonSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    if let error = newLessonError {
                        Text("⚠️ Fallo en la creación: \(error)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)

            }
        }
        .onAppear {
            Task { await apiService.fetchLessons() }
        }
        .sheet(isPresented: $showCreateLessonSheet) {
            CreateLessonSheet(
                isPresented: $showCreateLessonSheet,
                moduleID: module.id,
                onSave: { title, content, urlLink in
                    Task {
                        newLessonError = nil
                        let result = await apiService.createLesson(
                            title: title,
                            contentText: content.isEmpty ? nil : content,
                            urlLink: urlLink.isEmpty ? nil : urlLink,
                            sortOrder: apiService.lessons.count + 1
                        )
                        
                        if result == nil {
                            newLessonError = apiService.errorMessage ?? "Error desconocido al crear la lección."
                        }
                    }
                }
            )
        }
        .sheet(item: $lessonToEdit) { lesson in
            EditLessonSheet(
                isPresented: $lessonToEdit.isNotNil,
                lesson: .constant(lesson),
                onUpdate: { updatedLesson in
                    Task {
                        _ = await apiService.updateLesson(lesson: updatedLesson)
                    }
                }
            )
        }
        .navigationTitle(module.title)
    }
}

