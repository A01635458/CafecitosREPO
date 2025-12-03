import Foundation
import Supabase
import SwiftUI
import Combine

@MainActor
class LessonsViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var completedLessons: [UUID: Bool] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil 



    func fetchLessons() async {
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
            print("Error:", error)
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
            print("Error:", error)
        }
    }

    func isCompleted(_ lesson: Lesson) -> Bool {
        completedLessons[lesson.id] ?? false
    }
}

