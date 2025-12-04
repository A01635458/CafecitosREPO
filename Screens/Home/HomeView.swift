import SwiftUI

private struct ModuleRow: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    
                Text(isCompleted ? "Completada" : "Pendiente")
                    .font(.system(size: 13))
                    .foregroundStyle(isCompleted ? .secondary : .secondary)
            }
            .accessibilityElement(children: .combine)
            
            Spacer()
            
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(isCompleted ? .green : Color(.systemGray3))
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.ka_surface)
        )
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        .accessibilityLabel("\(title), estado: \(isCompleted ? "Completada" : "Pendiente"). Toca dos veces para ir a la lección.")
    }
}


struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var animatedTotalProgress: Double = 0.0
    @ObservedObject var authViewModel: AuthViewModel
    
    @StateObject private var lessonsViewModel = LessonsViewModel()
    
    @State private var showingVoiceOverAlert = false
    
    private var greeting: String {
        if !authViewModel.fullname.isEmpty {
            return "¡Hola, \(authViewModel.fullname)!"
        } else {
            return "¡Hola!"
        }
    }
    
    private var funFactText: String {
        "¿Sabías que el café fue descubierto por un pastor etíope llamado Kaldi, que notó que sus cabras se volvían más activas después de comer frutos de café?"
    }
    
    private var recommendedLesson: Lesson? {
        lessonsViewModel.lessons.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.black)
                                Text("Bienvenido a KaapehApp")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: "https://images.pexels.com/photos/1695052/pexels-photo-1695052.jpeg")) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().scaledToFill()
                                } else {
                                    Color.gray.opacity(0.2)
                                }
                            }
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                                .accessibilityLabel("Foto de perfil del usuario")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fun Fact del Día")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.black)
                        Text(funFactText)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                        
                        Button("Escuchar dato curioso") {
                            authViewModel.voiceService.speak(funFactText)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("ka_coffee"))
                        
                    }
                    .padding(20)
                    .background(Color("ka_surface"))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal, 20)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Dato curioso: \(funFactText)")
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Siguiente lección recomendada")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)
                            .foregroundStyle(.black)
                        
                        if lessonsViewModel.isLoading {
                            HStack {
                                ProgressView()
                                Text("Cargando lecciones…")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        } else if let error = lessonsViewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No se pudo cargar la lección recomendada.")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            .padding(.horizontal, 20)
                        } else if let lesson = recommendedLesson {
                            NavigationLink {
                                LessonDetailView(lesson: lesson)
                            } label: {
                                ZStack(alignment: .bottomLeading) {
                                    
                                    if let urlString = lesson.bannerURL,
                                       let url = URL(string: urlString) {
                                        AsyncImage(url: url) { phase in
                                            if case .success(let image) = phase {
                                                image.resizable()
                                                    .scaledToFill()
                                                    .overlay(
                                                         Color.black.opacity(0.25)
                                                    )
                                                    .overlay(
                                                         LinearGradient(
                                                             colors: [
                                                                 .clear,
                                                                 .black.opacity(0.3),
                                                                 .black.opacity(0.75)
                                                             ],
                                                             startPoint: .center,
                                                             endPoint: .bottom
                                                         )
                                                    )
                                            } else {
                                                Color.gray.opacity(0.2)
                                            }
                                        }
                                    } else {
                                        Color.gray.opacity(0.2)
                                    }
                                    
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Spacer(minLength: 30)
                                        Text(lesson.title)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundStyle(.white)
                                            .lineLimit(2)
                                        Text(lesson.subtitle)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white.opacity(0.9))
                                            .lineLimit(2)
                                            .padding(.bottom, 10)
                                    }
                                    .padding(20)
                                }
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 20)
                            .accessibilityLabel("Lección recomendada: \(lesson.title). Toca dos veces para iniciar.")
                            
                        } else {
                            Text("Aún no hay lecciones disponibles ☕️📖")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Resumen de tus módulos")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)
                            .foregroundStyle(.black)
                        
                        if lessonsViewModel.isLoading {
                            HStack {
                                ProgressView()
                                Text("Cargando módulos…")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                        } else if let error = lessonsViewModel.errorMessage {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No se pudieron cargar tus módulos.")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                            .padding(.horizontal, 20)
                            
                        } else if lessonsViewModel.lessons.isEmpty {
                            Text("Aún no hay lecciones registradas.")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 20)
                            
                        } else {
                            VStack(spacing: 14) {
                                ForEach(lessonsViewModel.lessons) { lesson in
                                    let completed = lessonsViewModel.isCompleted(lesson)
                                    
                                    NavigationLink {
                                        LessonDetailView(lesson: lesson)
                                            .environmentObject(lessonsViewModel)
                                    } label: {
                                        ModuleRow(
                                            title: lesson.title,
                                            isCompleted: completed
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color.ka_bg.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 1.2)) {
                        
                        animatedTotalProgress = 0.65
                    }
                }
            }
            .task {
                if authViewModel.fullname.isEmpty{
                    await authViewModel.getInitialSession()
                }
                await lessonsViewModel.fetchLessons()
                
                if !authViewModel.hasAskedForVoiceOver {
                    showingVoiceOverAlert = true
                }
                
                authViewModel.voiceService.setIsEnabled(authViewModel.isVoiceOverActive)

                // 🌟 NUEVA LÓGICA: Narrar dato curioso al cargar la vista si VoiceOver está activo
                if authViewModel.isVoiceOverActive {
                    authViewModel.voiceService.speak("Dato curioso del día: \(funFactText)")
                }
            }
            
            .alert("Activar Narración de la App", isPresented: $showingVoiceOverAlert) {
                Button("Activar") {
                    authViewModel.setVoiceOverPreference(isEnabled: true)
                }
                Button("Ahora no") {
                    authViewModel.setVoiceOverPreference(isEnabled: false)
                }
            } message: {
                Text("¿Te gustaría activar la narración de audio de la aplicación para que te lea los logros y el progreso automáticamente? (Puedes cambiar esto en Configuración.)")
            }
        }
        .environmentObject(lessonsViewModel)
    }
}
