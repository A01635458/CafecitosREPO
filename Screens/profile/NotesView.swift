////
////  NotesView.swift
////  KaapehApp
////
//
//import SwiftUI
//import SwiftData
//
//struct NotesView: View {
//    @Environment(\.modelContext) private var context
//    @Query(sort: \NoteEntity.date, order: .reverse) private var notes: [NoteEntity]
//    
//    @State private var showEditor = false
//    @State private var editingNote: NoteEntity? = nil
//    @State private var showDetail: NoteEntity? = nil
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.ka_bg.ignoresSafeArea()
//                
//                VStack(alignment: .leading, spacing: 16) {
//                    HStack {
//                        Text("Notas")
//                            .font(.system(size: 34, weight: .bold, design: .rounded))
//                        Spacer()
//                        Button {
//                            editingNote = NoteEntity()
//                            showEditor = true
//                        } label: {
//                            Label("Nueva", systemImage: "plus.circle.fill")
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundStyle(Color.ka_coffee)
//                        }
//                        .padding(8)
//                        .background(.ultraThinMaterial)
//                        .clipShape(Capsule())
//                    }
//                    .padding(.top, 40)
//                    .padding(.horizontal, 24)
//                    
//                    if notes.isEmpty {
//                        Spacer()
//                        VStack(spacing: 12) {
//                            Image(systemName: "note.text")
//                                .font(.system(size: 54))
//                                .foregroundStyle(Color.ka_divider)
//                            Text("Aún no hay notas")
//                                .font(.system(size: 17))
//                                .foregroundStyle(.secondary)
//                        }
//                        Spacer()
//                    } else {
//                        ScrollView {
//                            LazyVStack(spacing: 14) {
//                                ForEach(notes) { note in
//                                    VStack(alignment: .leading, spacing: 6) {
//                                        Text(note.title.isEmpty ? "Sin título" : note.title)
//                                            .font(.system(size: 18, weight: .semibold))
//                                            .foregroundStyle(Color.ka_coffee)
//                                        Text(note.content.isEmpty ? "Sin contenido" : note.content)
//                                            .font(.system(size: 14))
//                                            .foregroundStyle(.secondary)
//                                            .lineLimit(2)
//                                    }
//                                    .padding(18)
//                                    .background(.ultraThinMaterial)
//                                    .clipShape(RoundedRectangle(cornerRadius: 18))
//                                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
//                                    .padding(.horizontal, 20)
//                                    .onTapGesture {
//                                        showDetail = note
//                                    }
//                                }
//                            }
//                            .padding(.vertical, 20)
//                        }
//                    }
//                }
//                
//                // Modal para nueva nota
//                if showEditor, let note = editingNote {
//                    NotePopupEditor(note: note, onSave: {
//                        if !notes.contains(note) { context.insert(note) }
//                        try? context.save()
//                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
//                            showEditor = false
//                        }
//                    }, onCancel: {
//                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
//                            showEditor = false
//                        }
//                    })
//                    .zIndex(1)
//                    .transition(.scale)
//                }
//            }
//            // Pantalla completa tipo “Apple Notes”
//            .navigationDestination(item: $showDetail) { note in
//                NoteDetailView(note: note, onDelete: {
//                    context.delete(note)
//                    try? context.save()
//                })
//            }
//        }
//    }
//}
//
////
//// MARK: - Vista de nota completa estilo Apple Notes
////
//struct NoteDetailView: View {
//    @Bindable var note: NoteEntity
//    @Environment(\.dismiss) private var dismiss
//    var onDelete: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // Encabezado tipo Apple Notes
//            HStack {
//                Button {
//                    dismiss()
//                } label: {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundStyle(Color.ka_coffee)
//                }
//                Spacer()
//                Button(role: .destructive) {
//                    onDelete()
//                    dismiss()
//                } label: {
//                    Image(systemName: "trash")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundStyle(.red)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 50)
//            .padding(.bottom, 10)
//            .background(Color.ka_surface)
//            .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.ka_divider), alignment: .bottom)
//            
//            // Contenido
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    TextField("Título", text: $note.title)
//                        .font(.system(size: 26, weight: .bold))
//                        .padding(.horizontal, 20)
//                        .padding(.top, 20)
//                        .foregroundStyle(Color.ka_coffee)
//                        .textFieldStyle(.plain)
//                    
//                    TextEditor(text: $note.content)
//                        .scrollContentBackground(.hidden)
//                        .font(.system(size: 17))
//                        .foregroundStyle(.primary)
//                        .frame(minHeight: 500)
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 40)
//                        .background(Color.ka_bg)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ka_divider.opacity(0.3)))
//                }
//            }
//            .onDisappear {
//                try? note.modelContext?.save()
//            }
//        }
//        .background(Color.ka_bg.ignoresSafeArea())
//        .navigationBarBackButtonHidden(true)
//        .navigationTitle("")
//        .navigationBarHidden(true)
//    }
//}
//
////
//// MARK: - Pop-up de creación (solo para agregar nuevas)
////
//struct NotePopupEditor: View {
//    @Bindable var note: NoteEntity
//    var onSave: () -> Void
//    var onCancel: () -> Void
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.35)
//                .ignoresSafeArea()
//                .onTapGesture { onCancel() }
//            
//            VStack(spacing: 18) {
//                Text("Nueva Nota")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundStyle(Color.ka_coffee)
//                    .padding(.top, 10)
//                
//                TextField("Título", text: $note.title)
//                    .padding()
//                    .background(Color.ka_surface)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ka_divider))
//                    .padding(.horizontal, 20)
//                
//                TextEditor(text: $note.content)
//                    .scrollContentBackground(.hidden)
//                    .padding()
//                    .frame(height: 180)
//                    .background(Color.ka_surface)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ka_divider))
//                    .padding(.horizontal, 20)
//                
//                HStack(spacing: 12) {
//                    Button(action: onCancel) {
//                        Text("Cancelar")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.ka_divider.opacity(0.4))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//                    Button(action: onSave) {
//                        Text("Guardar")
//                            .foregroundStyle(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.ka_coffee)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//                }
//                .padding(.horizontal, 20)
//            }
//            .padding(.vertical, 25)
//            .frame(maxWidth: 420)
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            .shadow(radius: 10)
//            .padding(.horizontal, 20)
//        }
//        .animation(.easeInOut, value: note)
//    }
//}
//


//#Preview {
//    NotesView()
//        .modelContainer(for: NoteEntity.self)
//}

//
//  NotesView.swift
//  KaapehApp
////
//
//import SwiftUI
//import SwiftData
//
//@Model
//final class NoteEntity {
//    var id: UUID
//    var title: String
//    var content: String
//    var date: Date
//
//    init(id: UUID = UUID(), title: String = "", content: String = "", date: Date = .now) {
//        self.id = id
//        self.title = title
//        self.content = content
//        self.date = date
//    }
//}
//
//struct NotesView: View {
//    @Environment(\.modelContext) private var context
//    @Query(sort: \NoteEntity.date, order: .reverse) private var notes: [NoteEntity]
//
//    @State private var showEditor = false
//    @State private var editingNote: NoteEntity? = nil
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color.ka_bg.ignoresSafeArea()
//
//                if notes.isEmpty {
//                    VStack(spacing: 10) {
//                        Spacer()
//                        Image(systemName: "note.text")
//                            .font(.system(size: 50))
//                            .foregroundStyle(.secondary)
//                        Text("Aún no hay notas")
//                            .foregroundStyle(.secondary)
//                        Spacer()
//                    }
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 30)
//                } else {
//                    List {
//                        ForEach(notes) { note in
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text(note.title.isEmpty ? "Sin título" : note.title)
//                                    .font(.headline)
//                                    .foregroundStyle(.primary)
//                                Text(note.content.isEmpty ? "Sin contenido" : note.content)
//                                    .font(.subheadline)
//                                    .foregroundStyle(.secondary)
//                                    .lineLimit(2)
//                                Text(note.date.formatted(date: .abbreviated, time: .shortened))
//                                    .font(.caption2)
//                                    .foregroundStyle(.secondary)
//                            }
//                            .padding(.vertical, 6)
//                            .onTapGesture {
//                                editingNote = note
//                            }
//                        }
//                        .onDelete(perform: deleteNotes)
//                    }
//                    .listStyle(.insetGrouped)
//                }
//            }
//            .navigationTitle("Notas")
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        withAnimation {
//                            showEditor = true
//                        }
//                    } label: {
//                        Label("Agregar", systemImage: "plus.circle.fill")
//                            .foregroundStyle(Color.ka_coffee)
//                    }
//                }
//            }
//            .sheet(item: $editingNote) { note in
//                NoteDetailView(note: note)
//            }
//            .sheet(isPresented: $showEditor) {
//                AddNoteView()
//                    .presentationDetents([.medium, .large])
//                    .presentationCornerRadius(20)
//            }
//        }
//    }
//
//    private func deleteNotes(at offsets: IndexSet) {
//        for index in offsets {
//            context.delete(notes[index])
//        }
//        try? context.save()
//    }
//}
//
//struct AddNoteView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.modelContext) private var context
//
//    @State private var title = ""
//    @State private var content = ""
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                TextField("Título", text: $title)
//                    .padding()
//                    .background(Color.ka_surface)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                TextEditor(text: $content)
//                    .scrollContentBackground(.hidden)
//                    .frame(height: 200)
//                    .padding()
//                    .background(Color.ka_surface)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                Spacer()
//            }
//            .padding(20)
//            .navigationTitle("Nueva nota")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancelar") { dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Guardar") {
//                        let note = NoteEntity(title: title, content: content, date: .now)
//                        context.insert(note)
//                        try? context.save()
//                        dismiss()
//                    }
//                    .disabled(title.isEmpty && content.isEmpty)
//                }
//            }
//        }
//    }
//}
//
//struct NoteDetailView: View {
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.modelContext) private var context
//
//    @Bindable var note: NoteEntity
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                TextField("Título", text: $note.title)
//                    .padding()
//                    .background(Color.ka_surface)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                TextEditor(text: $note.content)
//                    .scrollContentBackground(.hidden)
//                    .frame(height: 300)
//                    .padding()
//                    .background(Color.ka_surface)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                Spacer()
//            }
//            .padding(20)
//            .navigationTitle("Editar nota")
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cerrar") { dismiss() }
//                }
//                ToolbarItem(placement: .destructiveAction) {
//                    Button("Borrar") {
//                        context.delete(note)
//                        try? context.save()
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    NotesView()
//        .modelContainer(for: NoteEntity.self)
//}


//
//  NotesView.swift
//  KaapehApp
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \NoteEntity.date, order: .reverse) private var notes: [NoteEntity]

    @State private var showEditor = false
    @State private var editingNote: NoteEntity?

    var body: some View {
        NavigationStack {
            ZStack {
                Text("Notas")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                Color.ka_bg.ignoresSafeArea()

                if notes.isEmpty {
                    VStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "note.text")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                            .foregroundStyle(.black)
                        Text("Aún no hay notas")
                            .foregroundStyle(.secondary)
                            .foregroundStyle(.black)
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                } else {
                    List {
                        ForEach(notes) { note in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(note.title.isEmpty ? "Sin título" : note.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .foregroundStyle(.black)
                                Text(note.content.isEmpty ? "Sin contenido" : note.content)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .foregroundStyle(.black)
                                Text(note.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture { editingNote = note }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Notas")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditor = true
                    } label: {
                        Label("Agregar", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.ka_coffee)
                    }
                }
            }
            .sheet(item: $editingNote) { note in
                NoteDetailView(note: note)
            }
            .sheet(isPresented: $showEditor) {
                AddNoteView()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(20)
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            context.delete(notes[index])
        }
        try? context.save()
    }
}

// MARK: - Add note
struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Título", text: $title)
                    .padding()
                    .background(Color.ka_surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                TextEditor(text: $content)
                    .scrollContentBackground(.hidden)
                    .frame(height: 200)
                    .padding()
                    .background(Color.ka_surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding(20)
            .navigationTitle("Nueva nota")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let note = NoteEntity(title: title, content: content, date: .now)
                        context.insert(note)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Detail view
struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Bindable var note: NoteEntity

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Título", text: $note.title)
                    .padding()
                    .background(Color.ka_surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                TextEditor(text: $note.content)
                    .scrollContentBackground(.hidden)
                    .frame(height: 300)
                    .padding()
                    .background(Color.ka_surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding(20)
            .navigationTitle("Editar nota")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Borrar") {
                        context.delete(note)
                        try? context.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NotesView()
        .modelContainer(for: NoteEntity.self)
}
