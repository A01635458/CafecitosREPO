import SwiftUI
import Combine

struct CompletedLessonsView: View {
    let lessons: [Lesson]
    
    var body: some View {
        VStack(spacing: 0) {
            // Fondo tipo Kaapeh
            List {
                if lessons.isEmpty {
                    Section {
                        Text("Aún no has completado ninguna lección ☕️📖")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(lessons) { lesson in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text(lesson.subtitle)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .navigationTitle("Lecciones completadas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

