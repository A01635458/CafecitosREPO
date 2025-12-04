import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @EnvironmentObject var lessonsViewModel: LessonsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                let urlString = lesson.bannerURL ?? ""
                
                LessonHeaderView(
                    imageURL: urlString,
                    title: lesson.title,
                    subtitle: lesson.subtitle
                )
                .frame(maxWidth: .infinity)
                
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contenido")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black)
                        
                        Text(lesson.content)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        
                        if let createdAt = lesson.createdAt {
                            Text("Creada el \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                        }
                    }
                    .padding(12)
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .background(Color.ka_bg.ignoresSafeArea())
        
        // Botón fijo abajo, sin tapar el contenido
        .safeAreaInset(edge: .bottom) {
            Button {
                Task {
                    await lessonsViewModel.markCompleted(lesson)
                }
            } label: {
                HStack {
                    Image(systemName:
                            lessonsViewModel.isCompleted(lesson)
                            ? "checkmark.circle.fill"
                            : "checkmark.circle"
                    )
                    
                    Text(
                        lessonsViewModel.isCompleted(lesson)
                        ? "Lección completada"
                        : "Marcar como completada"
                    )
                }
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    lessonsViewModel.isCompleted(lesson)
                    ? Color.ka_surface
                    : Color.ka_coffee
                )
                .foregroundColor(
                    lessonsViewModel.isCompleted(lesson)
                    ? .black
                    : .white
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Color.ka_bg.ignoresSafeArea())
        }
        .navigationTitle("Lección")
        .navigationBarTitleDisplayMode(.inline)
    }
}

