//
//  CafecitosAPIService.swift
//  KaapehApp
//
//  Created by Alumno on 21/11/25.
//

import Foundation
import Combine
import Supabase
import SwiftUI

//DTO para Módulos
struct ModuleDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let sort_order: Int
    let created_at: Date?
}

//DTO para crear Módulos
struct CreateModuleDTO: Codable {
    let title: String
    let description: String?
    let sort_order: Int?
}

//DTO para Lecciones
struct LessonDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let module_id: UUID
    let title: String
    let content_url: String? //Contiene el texto de leccion
    let sort_order: Int
    let created_at: Date?
}

//DTO para crear y actualizar Lecciones
struct CreateLessonDTO: Codable {
    let module_id: UUID
    let title: String
    let content_url: String?
    let sort_order: Int
}


// MARK: - API Service (Implementación CRUD unificada a Supabase)
class CafecitosAPIService: ObservableObject {
    static let shared = CafecitosAPIService()
    
    // Nombres de tablas de Supabase
    private let modulesTableName = "modules"
    private let lessonsTableName = "lessons"
    
    @Published var modules: [ModuleDTO] = []
    @Published var lessons: [LessonDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    //Leer
    func fetchModules() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedModules: [ModuleDTO] = try await supabase // Uso de la global 'supabase'
                .from(modulesTableName)
                .select()
                .order("sort_order", ascending: true)
                .execute()
                .value
            
            await MainActor.run {
                modules = fetchedModules
            }
            print("✅ Supabase GET módulos exitoso: \(fetchedModules.count) módulos obtenidos")
        } catch {
            await MainActor.run {
                errorMessage = "Error al obtener módulos de Supabase: \(error.localizedDescription)"
            }
            print("❌ Error GET modules (Supabase): \(error)")
            await MainActor.run { isLoading = false }
            return
        }
        
        await fetchLessons()
        await MainActor.run { isLoading = false }
    }
    
    //Crear
    func createModule(title: String, description: String, sortOrder: Int) async -> ModuleDTO? {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let newModule = CreateModuleDTO(
            title: title,
            description: description,
            sort_order: sortOrder
        )
        
        do {
            let createdModule: ModuleDTO = try await supabase // Uso de la global 'supabase'
                .from(modulesTableName)
                .insert(newModule)
                .select()
                .single()
                .execute()
                .value
            
            await fetchModules()
            await MainActor.run { isLoading = false }
            return createdModule
        } catch {
            await MainActor.run {
                errorMessage = "Error al crear módulo en Supabase: \(error.localizedDescription)"
                isLoading = false
            }
            return nil
        }
    }
    
    //Actualizar
    func updateModule(module: ModuleDTO) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let updateDTO = CreateModuleDTO(
            title: module.title,
            description: module.description,
            sort_order: module.sort_order
        )
        
        do {
            try await supabase // Uso de la global 'supabase'
                .from(modulesTableName)
                .update(updateDTO)
                .eq("id", value: module.id)
                .execute()
            
            await fetchModules()
            await MainActor.run { isLoading = false }
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Error al actualizar módulo en Supabase: \(error.localizedDescription)"
                isLoading = false
            }
            return false
        }
    }
    
    //Eliminar
    func deleteModule(moduleID: UUID) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            try await supabase
                .from(modulesTableName)
                .delete()
                .eq("id", value: moduleID)
                .execute()
            
            await fetchModules()
            await MainActor.run { isLoading = false }
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Error al eliminar módulo en Supabase: \(error.localizedDescription)"
                isLoading = false
            }
            return false
        }
    }
    
    //Leer
    func fetchLessons() async {
        do {
            let fetchedLessons: [LessonDTO] = try await supabase
                .from(lessonsTableName)
                .select()
                .order("sort_order", ascending: true)
                .execute()
                .value
            
            await MainActor.run {
                self.lessons = fetchedLessons
            }
            print("✅ Supabase GET lecciones exitoso: \(fetchedLessons.count) lecciones obtenidas")
            
        } catch {
            if self.errorMessage == nil {
                await MainActor.run {
                    self.errorMessage = "Error al obtener lecciones de Supabase: \(error.localizedDescription)"
                }
            }
            print("❌ Error GET lessons (Supabase): \(error)")
        }
    }
    
    //Creae
    func createLesson(dto: CreateLessonDTO) async -> LessonDTO? {
        do {
            let newLesson: LessonDTO = try await supabase // Uso de la global 'supabase'
                .from(lessonsTableName)
                .insert(dto)
                .select()
                .single()
                .execute()
                .value
            
            await fetchLessons()
            return newLesson
        } catch {
            await MainActor.run { errorMessage = "Error al crear lección en Supabase: \(error.localizedDescription)" }
            return nil
        }
    }
    
    //Actualizar
    func updateLesson(lessonID: UUID, dto: CreateLessonDTO) async -> LessonDTO? {
        do {
            let updatedLesson: LessonDTO = try await supabase
                .from(lessonsTableName)
                .update(dto)
                .eq("id", value: lessonID)
                .select()
                .single()
                .execute()
                .value
            
            await fetchLessons()
            return updatedLesson
        } catch {
            await MainActor.run { errorMessage = "Error al actualizar lección en Supabase: \(error.localizedDescription)" }
            return nil
        }
    }
    
    //Eliminar
    func deleteLesson(lessonID: UUID) async -> Bool {
        do {
            try await supabase
                .from(lessonsTableName)
                .delete()
                .eq("id", value: lessonID)
                .execute()
            
            await fetchLessons()
            return true
        } catch {
            await MainActor.run { errorMessage = "Error al eliminar lección en Supabase: \(error.localizedDescription)" }
            return false
        }
    }

    //Función de ayuda para la vista
    func lessons(for moduleID: UUID) -> [LessonDTO] {
        return lessons.filter { $0.module_id == moduleID }
                       .sorted { $0.sort_order < $1.sort_order }
    }
}
