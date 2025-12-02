//
//  CafecitosAPIService.swift
//  KaapehApp
//
//  Created by Alumno on 01/12/25.
//

import Foundation
import Supabase
import Combine

// MARK: - DTOs de Módulos

struct ModuleDTO: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var url_link: String?
    var is_active: Bool
    var sort_order: Int
    let created_at: Date?
}

struct CreateModuleDTO: Codable {
    let title: String
    let description: String?
    let url_link: String?
    let is_active: Bool
    let sort_order: Int
}

struct UpdateModuleDTO: Codable {
    let title: String
    let description: String?
    let url_link: String?
    let is_active: Bool
    let sort_order: Int
}

// MARK: - DTOs de Lecciones (Con CodingKeys para content_url)

struct LessonDTO: Codable, Identifiable, Hashable {
    let id: UUID
    var title: String
    var content: String?
    var url_link: String?
    var is_active: Bool
    var sort_order: Int
    let created_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case content = "content_url"
        case url_link, is_active, sort_order, created_at
    }
}

struct CreateLessonDTO: Codable {
    let title: String
    let content: String?
    let url_link: String?
    let sort_order: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case content = "content_url"
        case url_link, sort_order
    }
}

// MARK: - Clase del Servicio

class CafecitosAPIService: ObservableObject {
    static let shared = CafecitosAPIService()

    @Published var modules: [ModuleDTO] = []
    @Published var lessons: [LessonDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: Funciones de Módulos (CRUD de Módulos)

    @MainActor
    func fetchModules() async {
        isLoading = true
        errorMessage = nil
        do {
            modules = try await supabase.from("modules")
                .select()
                .order("sort_order", ascending: true)
                .execute()
                .value
            await fetchLessons()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func createModule(title: String, description: String, urlLink: String, isActive: Bool, sortOrder: Int) async -> ModuleDTO? {
        errorMessage = nil
        let newModule = CreateModuleDTO(
            title: title,
            description: description.isEmpty ? nil : description,
            url_link: urlLink.isEmpty ? nil : urlLink,
            is_active: isActive,
            sort_order: sortOrder
        )
        do {
            let createdModule: ModuleDTO = try await supabase.from("modules")
                .insert(newModule, returning: .representation)
                .select()
                .single()
                .execute()
                .value
            modules.append(createdModule)
            return createdModule
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    @MainActor
    func updateModule(module: ModuleDTO) async -> ModuleDTO? {
        errorMessage = nil
        let updateModule = UpdateModuleDTO(
            title: module.title,
            description: module.description,
            url_link: module.url_link,
            is_active: module.is_active,
            sort_order: module.sort_order
        )
        do {
            let updatedModule: ModuleDTO = try await supabase.from("modules")
                .update(updateModule)
                .eq("id", value: module.id)
                .select()
                .single()
                .execute()
                .value
            if let index = modules.firstIndex(where: { $0.id == updatedModule.id }) {
                modules[index] = updatedModule
            }
            return updatedModule
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    @MainActor
    func updateModuleStatus(moduleID: UUID, isActive: Bool) async -> Bool {
        errorMessage = nil
        do {
            _ = try await supabase.from("modules")
                .update(["is_active": isActive])
                .eq("id", value: moduleID)
                .execute()
            if let index = modules.firstIndex(where: { $0.id == moduleID }) {
                modules[index].is_active = isActive
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @MainActor
    func deleteModule(moduleID: UUID) async -> Bool {
        errorMessage = nil
        do {
            _ = try await supabase.from("modules")
                .delete()
                .eq("id", value: moduleID)
                .execute()
            modules.removeAll(where: { $0.id == moduleID })
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: Funciones de Lecciones (CRUD de Lecciones)
    
    @MainActor
    func fetchLessons() async {
        errorMessage = nil
        do {
            lessons = try await supabase.from("lessons")
                .select()
                .order("sort_order", ascending: true)
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func createLesson(title: String, contentText: String?, urlLink: String?, sortOrder: Int) async -> LessonDTO? {
        errorMessage = nil
        let newLesson = CreateLessonDTO(
            title: title,
            content: contentText,
            url_link: urlLink?.isEmpty == false ? urlLink : nil,
            sort_order: sortOrder
        )
        do {
            let createdLesson: LessonDTO = try await supabase.from("lessons")
                .insert(newLesson, returning: .representation)
                .select()
                .single()
                .execute()
                .value
            lessons.append(createdLesson)
            return createdLesson
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    @MainActor
    func updateLesson(lesson: LessonDTO) async -> LessonDTO? {
        errorMessage = nil
        
        let updateData = CreateLessonDTO(
            title: lesson.title,
            content: lesson.content,
            url_link: lesson.url_link,
            sort_order: lesson.sort_order
        )
        
        do {
            let updatedLesson: LessonDTO = try await supabase.from("lessons")
                .update(updateData)
                .eq("id", value: lesson.id)
                .select()
                .single()
                .execute()
                .value
            
            if let index = lessons.firstIndex(where: { $0.id == updatedLesson.id }) {
                lessons[index] = updatedLesson
            }
            return updatedLesson
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    @MainActor
    func updateLessonStatus(lessonID: UUID, isActive: Bool) async -> Bool {
        errorMessage = nil
        do {
            _ = try await supabase.from("lessons")
                .update(["is_active": isActive])
                .eq("id", value: lessonID)
                .execute()
            if let index = lessons.firstIndex(where: { $0.id == lessonID }) {
                lessons[index].is_active = isActive
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    @MainActor
    func deleteLesson(lessonID: UUID) async -> Bool {
        errorMessage = nil
        do {
            _ = try await supabase.from("lessons")
                .delete()
                .eq("id", value: lessonID)
                .execute()
            lessons.removeAll(where: { $0.id == lessonID })
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
