////
////  HomeView.swift
////  KaapehApp
////
//
//import SwiftUI
//import AVFoundation
//
//struct HomeView: View {
//    @State private var showCamera = false
//    @State private var cameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Header
//                VStack(spacing: 8) {
//                    AsyncImage(url: URL(string: "https://images.pexels.com/photos/1695052/pexels-photo-1695052.jpeg")) { img in
//                        img.resizable().scaledToFill()
//                    } placeholder: { Color.gray.opacity(0.2) }
//                    .frame(width: 60, height: 60)
//                    .clipShape(Circle())
//
//                    Text("Káapeh México")
//                        .font(.system(size: 28, weight: .bold))
//                    Text("Aprende sobre el café")
//                        .foregroundStyle(.secondary)
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 20)
//                .background(Color.white)
//                .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.gray.opacity(0.2)), alignment: .bottom)
//
//                // Scroll
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 20) {
//                        // Hero
//                        ZStack(alignment: .bottomLeading) {
//                            AsyncImage(url: URL(string: "https://images.pexels.com/photos/4188233/pexels-photo-4188233.jpeg")) { img in
//                                img.resizable().scaledToFill()
//                            } placeholder: { Color.gray.opacity(0.2) }
//                            .frame(height: 200)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//
//                            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
//
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("Descubre el mundo del café")
//                                    .font(.system(size: 22, weight: .bold))
//                                    .foregroundStyle(.white)
//                                Text("Usa tu cámara para identificar plantas, frutos y granos")
//                                    .font(.system(size: 14))
//                                    .foregroundStyle(.white.opacity(0.85))
//                            }
//                            .padding(20)
//                        }
//
//                        // Botón escanear
//                        Button(action: handleScanTap) {
//                            Label("Escanear café", systemImage: "camera")
//                                .font(.system(size: 18, weight: .bold))
//                                .foregroundStyle(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 18)
//                                .background(Color.ka_coffee)
//                                .clipShape(RoundedRectangle(cornerRadius: 16))
//                        }
//
//                        // InfoCard
//                        InfoCard(
//                            title: "¿Cómo funciona?",
//                            text: "Apunta tu cámara a cualquier etapa del proceso del café para obtener información educativa instantánea.",
//                            systemIcon: "info.circle"
//                        )
//
//                        // Features
//                        HStack(spacing: 12) {
//                            FeatureCard(emoji: "🌱", title: "Plantas", text: "Robusta y Arábica")
//                            FeatureCard(emoji: "🔴", title: "Madurez", text: "Verde, amarillo, rojo")
//                            FeatureCard(emoji: "☕", title: "Tueste", text: "Claro a oscuro")
//                        }
//                    }
//                    .padding(20)
//                }
//                .background(Color.ka_bg)
//            }
//        }
//        .sheet(isPresented: $showCamera) { CameraScreen() }
//    }
//
//    private func handleScanTap() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            showCamera = true
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                DispatchQueue.main.async {
//                    cameraAuthorized = granted
//                    showCamera = granted
//                }
//            }
//        default:
//            cameraAuthorized = false
//            showCamera = false
//        }
//    }
//}
//
//// MARK: - FeatureCard
//private struct FeatureCard: View {
//    let emoji: String
//    let title: String
//    let text: String
//
//    var body: some View {
//        VStack(spacing: 8) {
//            Text(emoji).font(.system(size: 32))
//            Text(title).font(.system(size: 14, weight: .bold))
//            Text(text)
//                .font(.system(size: 12))
//                .foregroundStyle(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(16)
//        .background(Color.white)
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2)))
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//    }
//}
//
//#Preview {
//    HomeView()
//    
//}



//
//  HomeView.swift
//  KaapehApp
//

import SwiftUI
import AVFoundation

struct HomeView: View {
    @State private var showCamera = false
    @State private var cameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // MARK: - Header con progreso
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("¡Hola, Barista!")
                                    .font(.system(size: 24, weight: .bold))
                                Text("Listo para aprender más sobre el café ☕️")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: "https://images.pexels.com/photos/1695052/pexels-photo-1695052.jpeg")) { img in
                                img.resizable().scaledToFill()
                            } placeholder: { Color.gray.opacity(0.2) }
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Progreso general")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("65%")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: 0.65)
                                .tint(.ka_coffee)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    // MARK: - Hero principal
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: URL(string: "https://images.pexels.com/photos/4188233/pexels-photo-4188233.jpeg")) { img in
                            img.resizable().scaledToFill()
                        } placeholder: { Color.gray.opacity(0.2) }
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Explora el proceso del café")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Escanea y aprende desde la planta hasta la taza.")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Botón escanear
                    Button(action: handleScanTap) {
                        Label("Escanear planta o grano", systemImage: "camera.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.ka_coffee)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .ka_coffee.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Sección de lecciones
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rutas de aprendizaje")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            NavigationLink(destination: PlantLessonView()) {
                                LessonCard(
                                    emoji: "🌱",
                                    title: "Iniciando con la planta",
                                    subtitle: "Descubre el origen y variedades del cafeto.",
                                    progress: 0.8
                                )
                            }
                            
                            NavigationLink(destination: CacaoLessonView()) {
                                LessonCard(
                                    emoji: "🍫",
                                    title: "Del cacao a la especialidad",
                                    subtitle: "Entiende la conexión entre granos, fermentación y sabor.",
                                    progress: 0.45
                                )
                            }
                            
                            NavigationLink(destination: RoastingLessonView()) {
                                LessonCard(
                                    emoji: "🔥",
                                    title: "Tueste y aroma",
                                    subtitle: "Aprende cómo el calor transforma el sabor del café.",
                                    progress: 0.2
                                )
                            }
                            
                            NavigationLink(destination: TastingLessonView()) {
                                LessonCard(
                                    emoji: "☕️",
                                    title: "Cata y especialidades",
                                    subtitle: "Identifica perfiles y notas del café de especialidad.",
                                    progress: 0.6
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer().frame(height: 60)
                }
                .padding(.bottom, 20)
            }
            .background(Color.ka_bg.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCamera) { CameraScreen() }
    }
    
    // MARK: - Handle camera
    private func handleScanTap() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraAuthorized = granted
                    showCamera = granted
                }
            }
        default:
            cameraAuthorized = false
            showCamera = false
        }
    }
}

// MARK: - LessonCard
private struct LessonCard: View {
    let emoji: String
    let title: String
    let subtitle: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(emoji).font(.system(size: 28))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            ProgressView(value: progress)
                .tint(.ka_coffee)
        }
        .padding(16)
        .background(Color.ka_surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    PreviewEnvironment {
        HomeView()
    }
}
