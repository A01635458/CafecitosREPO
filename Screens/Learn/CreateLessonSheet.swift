//
//  CreateLessonSheet.swift
//  KaapehApp
//
//  Created by Alumno on 01/12/25.
//

import SwiftUI
struct CreateLessonSheet: View {
    @Binding var isPresented: Bool
    let moduleID: UUID
    let onSave: (String, String, String) -> Void
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var urlLink: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información de la Lección") {
                    TextField("Título de la lección (Requerido)", text: $title)
                }
                
                Section("Contenido de la Lección") {
                    TextField("Contenido de texto (Opcional)", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                    TextField("URL de Video (Opcional)", text: $urlLink)
                }
            }
            .navigationTitle("Crear Nueva Lección")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        onSave(title, content, urlLink)
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
