import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel = LessonsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: Header
                HStack(spacing: 12) {
                    Text("Aprender")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
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
                
                // MARK: Lista de lecciones
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
                                
                                Button {
                                    Task { await viewModel.fetchLessons() }
                                } label: {
                                    Text("Reintentar")
                                        .font(.system(size: 16, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.ka_coffee)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
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
                                NavigationLink {
                                    LessonDetailView(lesson: lesson)
                                } label: {
                                    LessonCard(lesson: lesson)
                                }
                                .buttonStyle(.plain)
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

// MARK: - Card de lección, estilo Kaapeh

private struct LessonCard: View {
    let lesson: Lesson
    
    var body: some View {
        Card {
            HStack(spacing: 16) {
                // Imagen/banner cuadrado como avatar
                if let urlString = lesson.bannerURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color(red: 0.93, green: 0.86, blue: 0.74)
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Color(red: 0.93, green: 0.86, blue: 0.74)
                        @unknown default:
                            Color(red: 0.93, green: 0.86, blue: 0.74)
                        }
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    ZStack {
                        Color(red: 0.93, green: 0.86, blue: 0.74)
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.ka_coffee)
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                    
                    Text(previewText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    
                    if let createdAt = lesson.createdAt {
                        Text(createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
    }
    
    private var previewText: String {
        if lesson.content.count > 80 {
            String(lesson.content.prefix(80)) + "…"
        } else {
            lesson.content
        }
    }
}

