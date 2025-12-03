//
//  ScansViewModel.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import Foundation
import Combine
import Supabase

@MainActor
final class ScansViewModel: ObservableObject {
    @Published var scans: [ScanModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchScans() async {
        isLoading = true
        errorMessage = nil
                
        guard let user = supabase.auth.currentUser else {
            self.errorMessage = "No se identifico el usuario."
            isLoading = false
            return
        }

        do {
            let data: [ScanModel] = try await supabase
                .from("scans")
                .select()
                .eq("user_id", value: user.id)
                .order("captured_at", ascending: false)
                .execute()
                .value

            self.scans = data

        } catch {
            self.errorMessage = "Error al cargar scans: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
