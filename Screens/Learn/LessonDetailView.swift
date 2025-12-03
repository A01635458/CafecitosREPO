import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @EnvironmentObject var lessonsViewModel: LessonsViewModel
    
    var body: some View {
        ZStack {
            // Fondo
            Color.ka_bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        let urlString = lesson.bannerURL ?? ""
                        
                        LessonHeaderView(
                            imageURL: urlString,
                            title: lesson.title,
                            subtitle: lesson.subtitle
                        )
                        
                        Text(lesson.content)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        if let createdAt = lesson.createdAt {
                            Text("Creada el \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
               
                Spacer(minLength: 0)
            }
            
       
            VStack {
                Spacer()
                
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
                .padding(.bottom, 20)
                .ignoresSafeArea(.keyboard)  
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Lección")
    }
}

