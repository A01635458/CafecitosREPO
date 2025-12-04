import SwiftUI
import SwiftData

struct LearnView: View {
    @StateObject private var viewModel = LessonsViewModel()
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Aprender")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                        
                    Spacer()
                    
                    //Botón de Descargar
                    Button {
                        Task {
                            await viewModel.downloadAndSaveLessons(modelContext: modelContext)
                        }
                    } label: {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.ka_coffee)
                    }
                    
                    //Botón de Ver Descargas
                    NavigationLink(destination: DownloadedLessonsView()) {
                        Image(systemName: "tray.and.arrow.down.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.ka_coffee)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
                .background(Color.ka_surface)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.ka_divider),
                    alignment: .bottom
                )
                
                ScrollView {
                    VStack() {
                        if viewModel.isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                Text("Cargando lecciones…")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 24)
                            
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 12) {
                                Text("Ocurrió un error al cargar las lecciones.")
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 24)
                            
                        } else if viewModel.lessons.isEmpty {
                            VStack(spacing: 12) {
                                Text("Aún no hay lecciones ☕️📖")
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                Text("Pronto podrás aprender más sobre el mundo del café.")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 24)
                            
                        } else {
                            ForEach(viewModel.lessons) { lesson in
                                NavigationLink(
                                    destination: LessonDetailView(lesson: lesson),
                                    label: {
                                        LessonCard(lesson: lesson)
                                            .buttonStyle(.plain)
                                    }
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                        }
                    }
                }
                .background(Color.ka_bg)
            }
        }
        .environmentObject(viewModel)
        .task {
            await viewModel.fetchLessons()
        }
    }
}

private struct LessonCard: View {
    let lesson: Lesson
    
    var body: some View {
        Card {
            HStack(spacing: 14) {
                
                // MARK: - Imagen
                lessonImage
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                // MARK: - Textos alineados
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                    
                    Text(lesson.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    if let createdAt = lesson.createdAt {
                        Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 4)
                
                Spacer()
                
                // MARK: - Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
        }
    }
    
    // MARK: - Imagen modular
    private var lessonImage: some View {
        Group {
            if let urlString = lesson.bannerURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color(red: 0.93, green: 0.86, blue: 0.74)
                            .overlay(ProgressView())
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
    }
    
    private var placeholder: some View {
        Color(red: 0.93, green: 0.86, blue: 0.74)
            .overlay(
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.brown)
            )
    }
}

