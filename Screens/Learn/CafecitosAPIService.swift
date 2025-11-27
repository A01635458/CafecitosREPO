//
//  CafecitosAPIService.swift
//  KaapehApp
//
//  Created by Alumno on 26/11/25.
//

import Foundation
import Combine
import Supabase
import SwiftUI


//Estrctura del modulo
struct ModuleDTO: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var url_link: String?
    var is_active: Bool
    var sort_order: Int
    let created_at: Date?
}

//Creacion de modulo
struct CreateModuleWithActiveDTO: Codable {
    let title: String
    let description: String?
    let url_link: String?
    let is_active: Bool
    let sort_order: Int
}

struct CreateModuleDTO: Codable {
    let title: String
    let description: String?
    let url_link: String?
    let sort_order: Int
}

//Estrctura de leccion
struct LessonDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let module_id: UUID
    let title: String
    var content_url: String?
    var url_link: String?
    var is_active: Bool
    let sort_order: Int
    let created_at: Date?
}

//Crear leccion
struct CreateLessonDTO: Codable {
    let module_id: UUID
    let title: String
    let content_url: String?
    let url_link: String?
    let sort_order: Int
}

//Llama la api
class CafecitosAPIService: ObservableObject {
    static let shared = CafecitosAPIService()
    
    private let modulesTableName = "modules"
    private let lessonsTableName = "lessons"
    
    @Published var modules: [ModuleDTO] = []
    @Published var lessons: [LessonDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    func fetchModules() async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            let fetchedModules: [ModuleDTO] = try await supabase
                .from(modulesTableName).select().order("sort_order", ascending: true).execute().value
            await MainActor.run { modules = fetchedModules }
        } catch {
            await MainActor.run { errorMessage = "Error al obtener módulos: \(error.localizedDescription)" }
        }
        await fetchLessons()
        await MainActor.run { isLoading = false }
    }
    
    //Crea el modulo
    func createModule(title: String, description: String, urlLink: String?, isActive: Bool, sortOrder: Int) async -> ModuleDTO? {
        await MainActor.run { isLoading = true; errorMessage = nil }
        
        let newModule = CreateModuleWithActiveDTO(
            title: title,
            description: description,
            url_link: urlLink,
            is_active: isActive,
            sort_order: sortOrder
        )
        
        do {
            let createdModule: ModuleDTO = try await supabase
                .from(modulesTableName).insert(newModule).select().single().execute().value
            await fetchModules()
            await MainActor.run { isLoading = false }
            return createdModule
        } catch {
            await MainActor.run { errorMessage = "Error al crear módulo: \(error.localizedDescription)"; isLoading = false }
            return nil
        }
    }
    
    //Actualiza modulos
    func updateModule(module: ModuleDTO) async -> Bool {
        await MainActor.run { isLoading = true; errorMessage = nil }
        let updateDTO = ModuleDTO(id: module.id, title: module.title, description: module.description, url_link: module.url_link, is_active: module.is_active, sort_order: module.sort_order, created_at: module.created_at)
        do {
            try await supabase.from(modulesTableName).update(updateDTO).eq("id", value: module.id).execute()
            await fetchModules()
            await MainActor.run { isLoading = false }
            return true
        } catch {
            await MainActor.run { errorMessage = "Error al actualizar módulo: \(error.localizedDescription)"; isLoading = false }
            return false
        }
    }
    
    //Elimina modulos
    func deleteModule(moduleID: UUID) async -> Bool {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            try await supabase.from(modulesTableName).delete().eq("id", value: moduleID).execute()
            await fetchModules()
            await MainActor.run { isLoading = false }
            return true
        } catch {
            await MainActor.run { errorMessage = "Error al eliminar módulo: \(error.localizedDescription)"; isLoading = false }
            return false
        }
    }
    
    func updateModuleStatus(moduleID: UUID, isActive: Bool) async -> Bool {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            try await supabase
                .from(modulesTableName)
                .update(["is_active": isActive])
                .eq("id", value: moduleID)
                .execute()
            await fetchModules()
            await MainActor.run { isLoading = false }
            return true
        } catch {
            await MainActor.run { errorMessage = "Error al actualizar estado de módulo: \(error.localizedDescription)"; isLoading = false }
            return false
        }
    }
    
    //Lee lecciones
    func fetchLessons() async {
        do {
            let fetchedLessons: [LessonDTO] = try await supabase
                .from(lessonsTableName).select().order("sort_order", ascending: true).execute().value
            await MainActor.run { self.lessons = fetchedLessons }
        } catch {
            if self.errorMessage == nil { await MainActor.run { self.errorMessage = "Error al obtener lecciones: \(error.localizedDescription)" } }
        }
    }
    
    //Elimina lecciones
    func deleteLesson(lessonID: UUID) async -> Bool {
        do {
            try await supabase.from(lessonsTableName).delete().eq("id", value: lessonID).execute()
            await fetchLessons()
            return true
        } catch {
            await MainActor.run { errorMessage = "Error al eliminar lección: \(error.localizedDescription)" }
            return false
        }
    }

    func lessons(for moduleID: UUID) -> [LessonDTO] {
        return lessons.filter { $0.module_id == moduleID }.sorted { $0.sort_order < $1.sort_order }
    }
    
    //Crea lecciones
    func createLesson(moduleID: UUID, title: String, contentURL: String?, urlLink: String?, sortOrder: Int) async -> LessonDTO? {
        await MainActor.run { isLoading = true; errorMessage = nil }
        
        let newLesson = CreateLessonDTO(
            module_id: moduleID,
            title: title,
            content_url: contentURL,
            url_link: urlLink,
            sort_order: sortOrder
        )
        
        do {
            let createdLesson: LessonDTO = try await supabase
                .from(lessonsTableName)
                .insert(newLesson)
                .select()
                .single()
                .execute()
                .value
            
            await fetchLessons()
            await MainActor.run { isLoading = false }
            return createdLesson
        } catch {
            await MainActor.run { errorMessage = "Error al crear lección: \(error.localizedDescription)"; isLoading = false }
            return nil
        }
    }
    
    //Actualiza lecciones
    func updateLessonStatus(lessonID: UUID, isActive: Bool) async -> Bool {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            try await supabase
                .from(lessonsTableName)
                .update(["is_active": isActive])
                .eq("id", value: lessonID)
                .execute()
            await fetchLessons()
            await MainActor.run { isLoading = false }
            return true
        } catch {
            await MainActor.run { errorMessage = "Error al actualizar estado de lección: \(error.localizedDescription)"; isLoading = false }
            return false
        }
    }
}
