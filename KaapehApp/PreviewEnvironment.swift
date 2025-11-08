//
//  PreviewEnvironment.swift
//  KaapehApp
//
//  Created by Luisa Cardona on 07/11/25.
//

import Foundation

import SwiftUI
import SwiftData

/// Un entorno compartido para que todos los #Preview se vean igual que la app real
struct PreviewEnvironment<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .tint(.ka_coffee)                         // tu color principal
            .modelContainer(for: NoteEntity.self, inMemory: true) // datos temporales pero compartidos
            .environment(\.colorScheme, .light)       // modo claro por default
            .background(Color.ka_bg)                  // fondo global
    }
}
