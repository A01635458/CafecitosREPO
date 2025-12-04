//
//  AchievementsViewModel.swift
//  KaapehApp
//
//  Created by Alumno on 03/12/25.
//

import Foundation
import Supabase
import SwiftUI
import Combine

struct Achievement {
    let name: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}

class AchievementsViewModel: ObservableObject {
    @Published var completedLessonsCount: Int? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    @Published var currentAchievement: Achievement = Achievement(
        name: "No ha iniciado lecciones",
        description: "Comienza una lección para ganar tu primera insignia.",
        icon: "cup.and.saucer",
        isUnlocked: false
    )

    private let beginnerAchievement = Achievement(
        name: "Cafetero Principiante",
        description: "¡Has completado tu primera lección!",
        icon: "cup.and.saucer.fill",
        isUnlocked: true
    )
    private let intermediateAchievement = Achievement(
        name: "Cafetero Intermedio",
        description: "¡Ya dominas los conceptos básicos del café!",
        icon: "beans.and.cup.and.saucer.fill",
        isUnlocked: true
    )
    private let advancedAchievement = Achievement(
        name: "Cafetero Avanzado",
        description: "Un experto en café. ¡Tienes un conocimiento profundo!",
        icon: "medal.fill",
        isUnlocked: true
    )

    @MainActor
    func fetchCompletedLessonsCount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let session = try? await supabase.auth.session else {
                 throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado."])
            }
            let userId = session.user.id
            
            let response = try await supabase
                .from("lesson_progress")
                .select("id", count: .exact)
                .eq("user_id", value: userId)
                .eq("completed", value: true)
                .execute()

            let count = response.count ?? 0
            self.completedLessonsCount = count
            updateAchievement(count: count)
            
        } catch {
            debugPrint("Error fetching completed lessons count:", error)
            self.errorMessage = "Error al cargar el progreso de logros: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    private func updateAchievement(count: Int) {
        if count >= 7 {
            currentAchievement = advancedAchievement
        } else if count >= 2 {
            currentAchievement = intermediateAchievement
        } else if count >= 1 {
            currentAchievement = beginnerAchievement
        }
    }
}
