import SwiftUI

struct AchievementsView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var viewModel = AchievementsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Logros")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
                
                Button {
                    Task { await viewModel.fetchCompletedLessonsCount() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 22, weight: .semibold))
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
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    if viewModel.isLoading {
                        ProgressView("Cargando logros...")
                            .padding(.top, 40)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("⚠️ Error: \(errorMessage)")
                            .foregroundStyle(.red)
                            .padding(.top, 40)
                            .padding(.horizontal, 20)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progreso de Lecciones")
                                .font(.system(size: 20, weight: .bold))
                            
                            HStack {
                                Text("Lecciones completadas:")
                                    .accessibilityLabel("Lecciones completadas")
                                Spacer()
                                Text("\(viewModel.completedLessonsCount ?? 0)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.ka_coffee)
                                    .accessibilityLabel("\(viewModel.completedLessonsCount ?? 0) lecciones")
                            }
                            .padding()
                            .background(Color.ka_surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        Text("Tu Logro Actual")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        Card {
                            VStack(spacing: 16) {
                                Image(systemName: viewModel.currentAchievement.icon)
                                    .font(.system(size: 48))
                                    .foregroundStyle(viewModel.currentAchievement.isUnlocked ? Color.ka_coffee : Color(.systemGray4))

                                Text(viewModel.currentAchievement.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.black)
                                    
                                Text(viewModel.currentAchievement.description)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                            }
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Logro actual: \(viewModel.currentAchievement.name). \(viewModel.currentAchievement.description)")
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .background(Color.ka_bg)
        }
        .navigationTitle("Logros")
        .navigationBarHidden(true)
        .background(Color.ka_bg.ignoresSafeArea(.all, edges: .bottom))
        
        // LÓGICA DE NARRACIÓN PROACTIVA
        .task {
            // Carga los datos primero
            await viewModel.fetchCompletedLessonsCount()
            
            // Si la narración está activa, narra el resumen
            if authViewModel.isVoiceOverActive {
                let achievementsCount = viewModel.completedLessonsCount ?? 0
                let achievementName = viewModel.currentAchievement.name
                
                let textToSpeak = "Página de Logros. Tienes \(achievementsCount) lecciones completadas. Tu logro actual es: \(achievementName)."
                authViewModel.voiceService.speak(textToSpeak)
            }
        }
    }
}

#Preview {
    AchievementsView()
}
