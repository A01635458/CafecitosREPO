import Foundation
import Supabase
import SwiftUI
import Combine
import SwiftData

@MainActor
class LessonsViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var completedLessons: [UUID: Bool] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    func fetchLessons() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response: [Lesson] = try await supabase
                .from("lessons")
                .select("*")
                .order("created_at", ascending: true)
                .execute()
                .value
            
            self.lessons = response
            try await fetchCompleted()
        } catch {
            print("Error fetching lessons:", error)
            errorMessage = "No se pudieron cargar las lecciones. Verifica tu conexión."
        }
    }
    func fetchCompleted() async throws {
        let session = try await supabase.auth.session
        let uid = session.user.id
        let rows: [LessonProgress] = try await supabase
            .from("lesson_progress")
            .select("*")
            .eq("user_id", value: uid)
            .execute()
            .value
        var map: [UUID: Bool] = [:]
        for row in rows {
            map[row.lesson_id] = row.completed
        }
        self.completedLessons = map
    }
    func markCompleted(_ lesson: Lesson) async {
        do {
            let session = try await supabase.auth.session
            let uid = session.user.id
            struct Body: Encodable {
                let user_id: UUID
                let lesson_id: UUID
                let completed: Bool
            }
            let body = Body(user_id: uid, lesson_id: lesson.id, completed: true)
            _ = try await supabase
                .from("lesson_progress")
                .upsert(body, onConflict: "user_id,lesson_id")
                .execute()
            completedLessons[lesson.id] = true
        } catch {
            print("Error marking lesson completed:", error)
        }
    }
    func isCompleted(_ lesson: Lesson) -> Bool {
        completedLessons[lesson.id] ?? false
    }
    
    func downloadAndSaveLessons(modelContext: ModelContext) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Lesson] = try await supabase
                .from("lessons")
                .select("*")
                .order("created_at", ascending: true)
                .execute()
                .value
            
            try modelContext.delete(model: LessonEntity.self)
            
            for lesson in response {
                let entity = LessonEntity(lesson: lesson)
                modelContext.insert(entity)
            }
            
            try modelContext.save()
            print("Lecciones descargadas y guardadas: \(response.count)")
            self.errorMessage = nil
            
        } catch {
            let downloadError = "Error al descargar o guardar: \(error.localizedDescription)"
            errorMessage = downloadError
            print(downloadError)
        }
        
        isLoading = false
    }
}

